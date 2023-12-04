from flask import Flask, jsonify
import requests

app_reverser = Flask(__name__)

@app_reverser.route('/')
def index():
    # As we know service can access other service using service name within kubernetes cluster. 
    # So, we will make request to first application for JSON.
    response = requests.get('http://service-to-expose-json:80/')
    
    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        # Reverse the "message" key in the JSON response
        json_response = response.json()
        reversed_message = json_response.get("message", "")[::-1]
        
        # Create a new JSON response with the reversed message
        reversed_json_response = {"id": json_response.get("id", ""), "message": reversed_message}
        return jsonify(reversed_json_response)
    else:
        # Return an error message if the request to the first application failed
        return jsonify({"error": "Failed to retrieve data from the first application"})

if __name__ == '__main__':
    app_reverser.run(host='0.0.0.0',port=5001)
#This Applicatin will run on specific port 5001