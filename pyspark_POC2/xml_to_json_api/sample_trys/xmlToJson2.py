from flask import Flask, jsonify, request
import xmltodict
import json
import os
from datetime import datetime

app = Flask(__name__)

# Define the source and target folders
SOURCE_FOLDER = '/home/aditya/adithyan/pyspark_POC/apis/xml_files'  # Folder to scan for XML files
TARGET_FOLDER = '/home/aditya/adithyan/pyspark_POC/apis/converted_files'  # Folder to store the converted JSON files

# Ensure the target folder exists
os.makedirs(TARGET_FOLDER, exist_ok=True)

@app.route('/convert_all', methods=['POST'])
def convert_all_xml_files():
    try:
        # Get a list of all XML files from the source folder
        xml_files = [f for f in os.listdir(SOURCE_FOLDER) if f.endswith('.xml')]

        if not xml_files:
            return jsonify({"message": "No XML files found in the source folder"}), 400

        # Loop through each XML file and convert it to JSON
        for xml_file in xml_files:
            source_path = os.path.join(SOURCE_FOLDER, xml_file)

            with open(source_path, 'r') as file:
                xml_content = file.read()

            # Parse XML to a Python dictionary
            data_dict = xmltodict.parse(xml_content)

            # Create a JSON filename with a timestamp to avoid conflicts
            json_filename = f"{os.path.splitext(xml_file)[0]}_{datetime.now().strftime('%Y%m%d%H%M%S')}.json"
            json_filepath = os.path.join(TARGET_FOLDER, json_filename)

            # Save the JSON data to the target folder
            with open(json_filepath, 'w') as json_file:
                json.dump(data_dict, json_file, indent=4)

        return jsonify({"message": f"All XML files have been successfully converted and saved to {TARGET_FOLDER}"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
