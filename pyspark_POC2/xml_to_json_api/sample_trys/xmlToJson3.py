from flask import Flask, request, jsonify
import xmltodict
import json
import os
from datetime import datetime
import uuid  # Import the uuid module

app = Flask(__name__)

# Folder to store converted JSON files
CONVERTED_JSON_FOLDER = '/home/aditya/adithyan/pyspark_POC/xml_to_json_api/converted_files'
os.makedirs(CONVERTED_JSON_FOLDER, exist_ok=True)

@app.route('/convert', methods=['POST'])
def convert_xml_to_json():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Read XML content from the uploaded file
        xml_content = file.read()
        data_dict = xmltodict.parse(xml_content)

        # Prepare a unique JSON filename using uuid and current timestamp
        unique_id = uuid.uuid4()  # Generate a unique identifier
        filename = f"{os.path.splitext(file.filename)[0]}_{unique_id}.json"
        filepath = os.path.join(CONVERTED_JSON_FOLDER, filename)

        # Convert the dictionary to JSON and save it
        with open(filepath, 'w') as json_file:
            json.dump(data_dict, json_file, indent=4)

        return jsonify({
            "message": f"File converted and saved to {filepath}"
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(port=5001, debug=True)
