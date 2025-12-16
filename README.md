# Django E-commerce Project

This is a Django-based e-commerce project with Docker, PostgreSQL, Redis, and Celery.

## Prerequisites

- Docker and Docker Compose installed on your system
- Python 3.8+
- Git

## Getting Started

1. Clone the repository:
   ```bash
   git clone <your-repository-url>
   cd <project-directory>
   ```

2. Create a `.env` file by copying the example:
   ```bash
   cp .env.example .env
   ```
   Then edit the `.env` file with your configuration.

3. Build and start the services:
   ```bash
   docker-compose up --build
   ```

4. Run database migrations:
   ```bash
   docker-compose exec web python manage.py migrate
   ```

5. Create a superuser (admin):
   ```bash
   docker-compose exec web python manage.py createsuperuser
   ```

6. The application will be available at: http://localhost:8000

## Project Structure

```
.
├── mysite/               # Django project root
│   ├── blogapp/         # Blog application
│   ├── myauth/          # Authentication app
│   ├── shopapp/         # Main shop application
│   ├── mysite/          # Project settings
│   └── manage.py        # Django management script
├── .dockerignore
├── .env.example        # Environment variables template
├── docker-compose.yml  # Docker Compose configuration
├── Dockerfile          # Docker configuration
└── README.md           # This file
```

## Available Services

- **Web**: Django application (http://localhost:8000)
- **DB**: PostgreSQL database
- **Redis**: In-memory data store
- **Celery**: Asynchronous task queue
- **Celery Beat**: Task scheduler

## Development

To run the development server:

```bash
docker-compose up --build
```

## Production Deployment

For production, make sure to:

1. Set `DEBUG=0` in `.env`
2. Configure proper `ALLOWED_HOSTS`
3. Set up a proper database backup strategy
4. Configure proper email settings
5. Set up proper static file serving (e.g., with Nginx)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
