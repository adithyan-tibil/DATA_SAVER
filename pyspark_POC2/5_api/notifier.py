from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

PROCESSOR_API_URL = 'http://localhost:5004/process'


@app.route('/notify', methods=['POST'])
def notify():
    try:
        input_data = request.json.get('data')
        input_type = request.json.get('input_type')
        output_type = request.json.get('output_type')

        if not input_data or not input_type or not output_type:
            return jsonify({"error": "Missing input data, input_type, or output_type"}), 400

        process_payload = {
            "input_type": input_type,
            "output_type": output_type,
            "data": input_data
        }
        process_response = requests.post(PROCESSOR_API_URL, json=process_payload)

        if process_response.status_code != 200:
            return jsonify({"error": "Failed to notify processor", "details": process_response.text}), 500

        processed_data = process_response.json()
        print("Transformed Data:", processed_data)
        return jsonify({"Success":"Successfully notified processor","processed data":processed_data})
        # print("Processor activated")

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(port=5005, debug=True)
