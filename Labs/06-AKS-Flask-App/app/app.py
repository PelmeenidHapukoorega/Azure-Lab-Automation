from flask import Flask, jsonify, render_template
import os
import math
import time
from kubernetes import client, config

app = Flask(__name__)

def get_pod_count():
    try:
        config.load_incluster_config()
        v1 = client.CoreV1Api()
        pods = v1.list_namespaced_pod(
            namespace="default",
            label_selector="app=simplemetrics"
        )
        print(f"Found {len(pods.items)} pods total")
        for p in pods.items:
            print(f"Pod: {p.metadata.name}, Phase: {p.status.phase}")
        running = [p for p in pods.items if p.status.phase == "Running"]
        return len(running)
    except Exception as e:
        print(f"Pod count error: {e}")
        return 1

@app.route("/")
def index():
    return render_template("index.html")

def get_pod_names():
    try:
        config.load_incluster_config()
        v1 = client.CoreV1Api()
        pods = v1.list_namespaced_pod(
            namespace="default",
            label_selector="app=simplemetrics"
        )
        return [p.metadata.name for p in pods.items if p.status.phase == "Running"]
    except Exception as e:
        print(f"Pod names error: {e}")
        return [os.environ.get("POD_NAME", "unknown")]
    
@app.route("/info")
def info():
    pod_names = get_pod_names()
    return jsonify({
        "pod_name": os.environ.get("POD_NAME", "unknown"),
        "pod_count": len(pod_names),
        "pod_names": pod_names,
        "status": "running"
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/load")
def load():
    start = time.time()
    result = sum(math.factorial(i) for i in range(1, 2000))
    for _ in range(100):
        result = sum(math.factorial(i) for i in range(1, 500))
    duration = round(time.time() - start, 4)
    return jsonify({
        "pod_name": os.environ.get("POD_NAME", "unknown"),
        "computation": "factorial sum 1-2000 x100",
        "duration_seconds": duration,
        "result_length": len(str(result))
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)