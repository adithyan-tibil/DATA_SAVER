from flask import Flask, request, jsonify ,json
import os

app = Flask(__name__)

output_dir = '/home/aditya/adithyan/pyspark_POC/text_convertion/api_output'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

@app.route('/store', methods=['POST'])
def receive_data():
    try:
        json_data = request.get_json()
        if json_data is None:
            return jsonify({"error": "Invalid JSON"}), 400

        filename = f"{output_dir}/data_{int(os.urandom(4).hex(), 16)}.json"  # Unique filename

        with open(filename, 'w') as json_file:
            json_file.write(json.dumps(json_data, indent=4))

        return jsonify({"message": "Data received and stored successfully!", "filename": filename}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)  