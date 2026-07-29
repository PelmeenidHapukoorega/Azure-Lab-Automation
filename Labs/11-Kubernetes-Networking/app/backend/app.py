from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "service": "backend",
        "message": "Backend is functional"
    })

@app.route('/')
def index():
    return jsonify({
        "service": "backend",
        "version": "1.0"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)