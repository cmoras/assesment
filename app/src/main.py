import os
import logging
import time
import uuid
from datetime import datetime, timezone
from flask import Flask, request, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from logging_config import configure_logging


# Configure structured logging
logger = configure_logging()

# Create Flask app
app = Flask(__name__)

# Prometheus metrics
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['endpoint']
)


@app.before_request
def before_request():
    """Attach request metadata for logging."""
    request.start_time = time.time()
    request.request_id = str(uuid.uuid4())


@app.after_request
def after_request(response):
    """Log request details and record metrics."""
    if request.endpoint not in ['metrics', 'favicon']:
        duration_ms = int((time.time() - request.start_time) * 1000)
        
        # Log request
        logger.info(
            "Request completed",
            extra={
                'request_id': request.request_id,
                'endpoint': request.path,
                'status_code': response.status_code,
                'duration_ms': duration_ms
            }
        )
        
        # Record Prometheus metrics
        http_requests_total.labels(
            endpoint=request.path,
            status=response.status_code
        ).inc()
        
        http_request_duration_seconds.labels(
            endpoint=request.path
        ).observe(duration_ms / 1000.0)
    
    return response


@app.route('/healthz', methods=['GET'])
def healthz():
    """Health check endpoint for Kubernetes probes."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now(timezone.utc).isoformat()
    }), 200


@app.route('/process', methods=['POST'])
def process():
    """Process data endpoint - echoes back input with metadata."""
    try:
        input_data = request.get_json(silent=True) or {}
        
        result = {
            'input': input_data,
            'processed_at': datetime.now(timezone.utc).isoformat(),
            'request_id': request.request_id,
            'processing_time_ms': int((time.time() - request.start_time) * 1000)
        }
        
        return jsonify(result), 200
    
    except Exception as e:
        logger.error(f"Error processing request: {e}", extra={'request_id': request.request_id})
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/metrics', methods=['GET'])
def metrics():
    """Prometheus metrics endpoint."""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    logger.info(f"Starting data pipeline service on port {port}")
    app.run(host='0.0.0.0', port=port)
