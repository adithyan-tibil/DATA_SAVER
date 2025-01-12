from flask import Flask, request, jsonify
import xmltodict
import json
import requests  # To make HTTP requests to the encrypting API

app = Flask(__name__)

ENCRYPT_API_URL = 'http://localhost:5003/encrypt'  # Adjust the URL based on the encrypting API

@app.route('/transform', methods=['POST'])
def convert():
    try:
        # Extract the input data
        data = request.get_json()
        if not data or 'input_type' not in data or 'output_type' not in data:
            return jsonify({"error": "Missing input_type or output_type"}), 400

        input_type = data['input_type']
        output_type = data['output_type']
        content = data.get('data')

        if not content:
            return jsonify({"error": "No data provided"}), 400

        # Convert based on input_type and output_type
        if input_type == 'xml' and output_type == 'json':
            data_dict = xmltodict.parse(content)
            # Convert the dictionary to JSON
            json_data = json.dumps(data_dict)
            # Call the encrypt API with the converted JSON data
            encrypt_response = requests.post(ENCRYPT_API_URL, json={"data": json_data})

            if encrypt_response.status_code == 200:
                return jsonify(encrypt_response.json()), 200
            else:
                return jsonify({"error": "Failed to encrypt data", "details": encrypt_response.text}), 500

        elif input_type == 'json' and output_type == 'xml':
            xml_data = xmltodict.unparse(content, pretty=True)
            # Call the encrypt API with the converted XML data
            encrypt_response = requests.post(ENCRYPT_API_URL, json={"data": xml_data})

            if encrypt_response.status_code == 200:
                return jsonify(encrypt_response.json()), 200
            else:
                return jsonify({"error": "Failed to encrypt data", "details": encrypt_response.text}), 500

        else:
            return jsonify({"error": "Unsupported input/output type combination"}), 400

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5002)
