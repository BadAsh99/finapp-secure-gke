# Build for amd64 to match GKE nodes (or do multi-arch with buildx)
FROM --platform=$BUILDPLATFORM python:3.11-slim

# Non-root user
RUN adduser --disabled-password --gecos "" --uid 10001 appuser
WORKDIR /app

# Copy app
COPY src/ /app/

# Pin libs (hadolint complaint)
RUN pip install --no-cache-dir gunicorn==21.2.0 flask==3.0.3

USER 10001
EXPOSE 5000

# Gunicorn on 0.0.0.0:5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "main:app"]
