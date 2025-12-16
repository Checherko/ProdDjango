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

# Run migrations and collect static files
RUN python /app/mysite/manage.py migrate --noinput

# Copy fixtures if they exist
COPY --chown=app:app mysite/fixtures/ /app/mysite/fixtures/

# Load fixtures if they exist
RUN if [ -f "/app/mysite/fixtures/fixtures.json" ]; then \
    python /app/mysite/manage.py loaddata /app/mysite/fixtures/fixtures.json; \
    fi

# Collect static files
RUN python /app/mysite/manage.py collectstatic --noinput

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "mysite.wsgi:application", "--chdir", "/app/mysite"]
