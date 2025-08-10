from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/healthz")
def health():
    return jsonify(status="ok")

@app.get("/")
def root():
    return jsonify(app="finapp-api", msg="hello from api")
