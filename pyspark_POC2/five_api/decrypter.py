from flask import Flask, request, jsonify
import base64
import requests  # To forward the request to transformer API
from Crypto.Cipher import AES

app = Flask(__name__)

SECRET_KEY = b'k92ldahavl97s428vxri7x89seoy79sm'
INIT_VECTOR = b'7dzhcnrb0016hmj3'

TRANSFORMER_API_URL = 'http://localhost:5002/transform'  # Adjust based on the transformer's API URL

def decrypt_file(encrypted_data_b64):
    encrypted_data = base64.b64decode(encrypted_data_b64)
    auth_tag = encrypted_data[-16:]
    ciphertext = encrypted_data[:-16]
    cipher = AES.new(SECRET_KEY, AES.MODE_GCM, nonce=INIT_VECTOR)
    decrypted_data = cipher.decrypt_and_verify(ciphertext, auth_tag)
    return decrypted_data


@app.route('/decrypt', methods=['POST'])
def decrypt_data():
    try:
        # Get input_type, output_type, and data from the request
        input_type = request.json.get('input_type')
        output_type = request.json.get('output_type')
        data = request.json.get('data')

        if not data:
            return jsonify({"error": "No data provided"}), 400
        if not input_type or not output_type:
            return jsonify({"error": "input_type and output_type must be provided"}), 400

        # Decrypt the data
        decrypted_data = decrypt_file(data)

        # Forward the decrypted data to the transformer API
        transformer_payload = {
            "input_type": input_type,
            "output_type": output_type,
            "data": decrypted_data.decode('utf-8')
        }

        # Send a POST request to the transformer API
        transformer_response = requests.post(TRANSFORMER_API_URL, json=transformer_payload)

        if transformer_response.status_code == 200:
            return jsonify(transformer_response.json()), 200
        else:
            return jsonify({"error": "Failed to transform data", "details": transformer_response.text}), 500

    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(port=5001, debug=True)
