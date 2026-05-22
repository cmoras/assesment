import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import pytest
import json
from main import app


@pytest.fixture
def client():
    """Create test client."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_healthz_endpoint(client):
    """Test health check endpoint returns 200 with status."""
    response = client.get('/healthz')
    
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'healthy'
    assert 'timestamp' in data


def test_process_endpoint_with_data(client):
    """Test process endpoint echoes back input with metadata."""
    input_data = {'test': 'data', 'value': 123}
    response = client.post(
        '/process',
        data=json.dumps(input_data),
        content_type='application/json'
    )
    
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['input'] == input_data
    assert 'processed_at' in data
    assert 'request_id' in data
    assert 'processing_time_ms' in data


def test_process_endpoint_empty_body(client):
    """Test process endpoint handles empty body."""
    response = client.post('/process', content_type='application/json')

    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['input'] == {}


def test_metrics_endpoint(client):
    """Test Prometheus metrics endpoint."""
    response = client.get('/metrics')
    
    assert response.status_code == 200
    assert b'http_requests_total' in response.data
    assert b'http_request_duration_seconds' in response.data
