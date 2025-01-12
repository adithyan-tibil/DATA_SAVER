from flask import Flask, request, jsonify
import base64
from Crypto.Cipher import AES

app = Flask(__name__)

# Encryption parameters
SECRET_KEY = b'k92ldahavl97s428vxri7x89seoy79sm'
INIT_VECTOR = b'7dzhcnrb0016hmj3'

def encrypt_data(data):
    cipher = AES.new(SECRET_KEY, AES.MODE_GCM, nonce=INIT_VECTOR)
    ciphertext, auth_tag = cipher.encrypt_and_digest(data.encode())
    encrypted_data = ciphertext + auth_tag
    return base64.b64encode(encrypted_data).decode()

@app.route('/encrypt', methods=['POST'])
def encrypt():
    try:
        # Get the input data from the request
        input_data = request.json.get('data')

        if not input_data:
            return jsonify({"error": "No data provided"}), 400

        # Encrypt the input data
        encrypted_data = encrypt_data(input_data)

        return jsonify({"encrypted_data": encrypted_data}), 200

    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(port=5003, debug=True)
