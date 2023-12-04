from flask import Flask, jsonify
import json

app_provider = Flask(__name__)

@app_provider.route('/')
def index():
    # Assuming the JSON file is in the same directory as your script
    with open('input_file.json', 'r') as file:
        json_response = json.load(file)
    return jsonify(json_response)

if __name__ == '__main__':
    app_provider.run(host='0.0.0.0', port=5002)
