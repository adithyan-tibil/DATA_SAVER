from flask import Flask, request, jsonify
import xmltodict
import json
import os
import base64
import uuid
import configparser
from Crypto.Cipher import AES

app = Flask(__name__)

CONVERTED_JSON_FOLDER = os.getenv('CONVERTED_JSON_FOLDER', '/app/json_files')
os.makedirs(CONVERTED_JSON_FOLDER, exist_ok=True)

config = configparser.ConfigParser()
config.read('config.ini')

SECRET_KEY = config['default']['SECRET_KEY'].encode('utf-8')
INIT_VECTOR = config['default']['INIT_VECTOR'].encode('utf-8')


def decrypt_file(encrypted_data_b64):
    encrypted_data = base64.b64decode(encrypted_data_b64)
    auth_tag = encrypted_data[-16:]
    ciphertext = encrypted_data[:-16]
    cipher = AES.new(SECRET_KEY, AES.MODE_GCM, nonce=INIT_VECTOR)
    decrypted_data = cipher.decrypt_and_verify(ciphertext, auth_tag)
    return decrypted_data

@app.route('/convert', methods=['POST'])
def convert_encrypted_xml_to_json():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        encrypted_data_b64 = file.read().decode('utf-8')
        decrypted_xml = decrypt_file(encrypted_data_b64)
        data_dict = xmltodict.parse(decrypted_xml)
        unique_id = uuid.uuid4()
        filename = f"{os.path.splitext(file.filename)[0]}_{unique_id}.json"
        filepath = os.path.join(CONVERTED_JSON_FOLDER, filename)

        with open(filepath, 'w') as json_file:
            json.dump(data_dict, json_file, indent=4)

        return jsonify({
            "message": f"File decrypted, converted, and saved to {filepath}"
        }), 200

    except ValueError as e:
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(port=5002, debug=True)
