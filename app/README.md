# Data Pipeline Application

Simple Python Flask data pipeline service with structured logging and Prometheus metrics.

## Endpoints

- `GET /healthz` - Health check endpoint
- `POST /process` - Process data (echoes back with metadata)
- `GET /metrics` - Prometheus metrics

## Local Development

### Install dependencies

```bash
pip install -r requirements-dev.txt
```

### Run tests

```bash
pytest tests/ -v
```

### Run application

```bash
python src/main.py
```

### Test endpoints

```bash
# Health check
curl http://localhost:5000/healthz

# Process data
curl -X POST http://localhost:5000/process \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Metrics
curl http://localhost:5000/metrics
```

## Docker

### Build

```bash
docker build -t data-pipeline:latest .
```

### Run

```bash
docker run -p 5000:5000 data-pipeline:latest
```

### Test

```bash
curl http://localhost:5000/healthz
```

## Configuration

- `PORT` - Server port (default: 5000)
- `LOG_LEVEL` - Logging level (default: INFO)
