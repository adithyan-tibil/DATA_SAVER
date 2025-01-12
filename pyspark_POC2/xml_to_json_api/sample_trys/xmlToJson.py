from flask import Flask, request, jsonify
import xmltodict

app = Flask(__name__)

@app.route('/convert', methods=['POST'])
def convert_xml_to_json():
    # Check if a file was uploaded
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']

    # Check if the uploaded file is valid
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Read the XML content and parse it
        xml_content = file.read()
        data_dict = xmltodict.parse(xml_content)

        # Convert the dict to JSON and return it
        return jsonify(data_dict), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
