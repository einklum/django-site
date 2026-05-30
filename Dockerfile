FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV POETRY_VIRTUALENVS_CREATE=false

RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
COPY poetry.lock .

RUN pip install --upgrade pip
RUN pip install poetry
RUN poetry install --no-root --no-interaction --no-ansi

COPY . .

CMD ["gunicorn", "app.wsgi:application", "--bind", "0.0.0.0:8000"]
