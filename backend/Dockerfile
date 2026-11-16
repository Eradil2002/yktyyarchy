FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /code

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gettext \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY requirements.txt /code/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /code/

# Expose port
EXPOSE 8000

# Entrypoint script for migrations and server start
RUN echo '#!/bin/sh\n\
python manage.py migrate --noinput\n\
if [ "$DEBUG" = "True" ]; then\n\
    python manage.py runserver 0.0.0.0:8000\n\
else\n\
    exec gunicorn config.wsgi:application \\\n\
        --bind 0.0.0.0:8000 \\\n\
        --workers 4 \\\n\
        --timeout 120 \\\n\
        --access-logfile - \\\n\
        --error-logfile - \\\n\
        --log-level info \\\n\
        --capture-output\n\
fi' > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

