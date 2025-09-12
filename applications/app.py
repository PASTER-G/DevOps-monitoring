from flask import Flask
from prometheus_client import generate_latest, Counter, Histogram, REGISTRY

app = Flask(__name__)

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'status_code'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency in seconds', ['endpoint'])

@app.route('/')
def hello():
    with REQUEST_LATENCY.labels(endpoint='/').time():
        REQUEST_COUNT.labels(method='GET', endpoint='/', status_code='200').inc()
        return "Hello, World! This is a monitored app."

@app.route('/metrics')
def metrics():
    return generate_latest(REGISTRY)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
