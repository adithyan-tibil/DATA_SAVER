from flask import Flask, request, jsonify
import xmltodict
import json

app = Flask(__name__)

@app.route('/convert', methods=['POST'])
def convert():
    try:
        # Extract the input data (it could be XML, JSON, or other formats)
        data = request.get_json()
        if not data or 'input_type' not in data or 'output_type' not in data:
            return jsonify({"error": "Missing input_type or output_type"}), 400

        input_type = data['input_type']
        output_type = data['output_type']
        content = data.get('data')  # Changed from 'content' to 'data'

        if not content:
            return jsonify({"error": "No data provided"}), 400

        # Convert based on input_type and output_type
        if input_type == 'xml' and output_type == 'json':
            data_dict = xmltodict.parse(content)
            return jsonify(data_dict)

        elif input_type == 'json' and output_type == 'xml':
            xml_data = xmltodict.unparse(content, pretty=True)
            return xml_data, 200, {'Content-Type': 'application/xml'}

        else:
            return jsonify({"error": "Unsupported input/output type combination"}), 400

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True,port=5002)
