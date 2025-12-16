FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DJANGO_DEBUG=1

# Set work directory
WORKDIR /app

# Create and set mysite as working directory
RUN mkdir -p /app/mysite
WORKDIR /app/mysite

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pipenv
RUN pip install --no-cache-dir pipenv

# Copy Pipfile and requirements.txt
COPY requirements.txt .

# Install project dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install additional dependencies
RUN pip install --no-cache-dir celery==5.3.4  # Убедитесь, что версия совместима с вашим проектом

# Copy the rest of the application
# Copy the rest of the application
COPY . /app/

# Create directory for static files
RUN mkdir -p /app/static
RUN mkdir -p /app/uploads

# Set environment variable for Django settings
ENV DJANGO_SETTINGS_MODULE=mysite.settings

# Install any additional requirements
RUN pip install --no-cache-dir psycopg2-binary

# Create entrypoint script
RUN cat > /app/entrypoint.sh << 'EOF'
#!/bin/bash
set -e

echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\q" >/dev/null 2>&1 ; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

cd /app/mysite

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Creating superuser if needed..."
python manage.py shell << 'PYCODE'
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
PYCODE

exec "$@"
EOF

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "mysite.wsgi:application", "--chdir", "/app/mysite"]

EXPOSE 8000
