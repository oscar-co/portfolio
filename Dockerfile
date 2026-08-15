FROM python:3.13-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

FROM base AS test

COPY requirements.txt requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt

COPY app.py pyproject.toml ./
COPY data ./data
COPY static ./static
COPY templates ./templates

RUN mypy
RUN python -c "from app import app; response = app.test_client().get('/'); assert response.status_code == 200"
RUN python -c "from app import app; response = app.test_client().get('/health'); assert response.get_json() == {'status': 'ok'}"

FROM base AS runtime

RUN groupadd --system portfolio \
    && useradd --system --gid portfolio --home-dir /app portfolio

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=portfolio:portfolio app.py ./
COPY --chown=portfolio:portfolio data ./data
COPY --chown=portfolio:portfolio static ./static
COPY --chown=portfolio:portfolio templates ./templates

USER portfolio

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"]

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
