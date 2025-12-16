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

# Set environment variable for Django settings
ENV DJANGO_SETTINGS_MODULE=mysite.settings

# Install any additional requirements
RUN pip install --no-cache-dir psycopg2-binary

# Run migrations
RUN python /app/mysite/manage.py migrate --noinput

# Collect static files
RUN python /app/mysite/manage.py collectstatic --noinput

# Create superuser if it doesn't exist (optional)
RUN echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python /app/mysite/manage.py shell

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "mysite.wsgi:application", "--chdir", "/app/mysite"]
