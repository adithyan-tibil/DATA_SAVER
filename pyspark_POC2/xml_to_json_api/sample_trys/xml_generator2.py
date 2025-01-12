from flask import Flask, jsonify, request
import random
import string
import xml.etree.ElementTree as ET
import requests
from io import BytesIO

app = Flask(__name__)

def generate_random_string(length=6):
    """Generate a random string of uppercase letters."""
    return ''.join(random.choices(string.ascii_uppercase, k=length))

def create_random_xml_data():
    """Generate random XML data structure."""
    root = ET.Element('data')

    category = random.choice(['user', 'book', 'order'])
    if category == 'user':
        for _ in range(random.randint(1, 5)):
            user = ET.SubElement(root, 'user')
            ET.SubElement(user, 'name').text = generate_random_string()
            ET.SubElement(user, 'age').text = str(random.randint(18, 65))
            ET.SubElement(user, 'email').text = f"{generate_random_string()}@example.com"
    elif category == 'book':
        for _ in range(random.randint(1, 5)):
            book = ET.SubElement(root, 'book')
            ET.SubElement(book, 'title').text = generate_random_string(8)
            ET.SubElement(book, 'author').text = generate_random_string()
            ET.SubElement(book, 'price').text = str(round(random.uniform(10.0, 100.0), 2))
    elif category == 'order':
        order = ET.SubElement(root, 'order')
        ET.SubElement(order, 'orderId').text = str(random.randint(1000, 9999))
        items = ET.SubElement(order, 'items')
        for _ in range(random.randint(1, 3)):
            item = ET.SubElement(items, 'item')
            ET.SubElement(item, 'name').text = generate_random_string(5)
            ET.SubElement(item, 'quantity').text = str(random.randint(1, 10))
            ET.SubElement(item, 'price').text = str(round(random.uniform(1.0, 50.0), 2))

    return ET.tostring(root, encoding='utf-8')

@app.route('/generate_and_send', methods=['POST'])
def generate_and_send():
    try:
        num_files = int(request.form.get('num_files', 1))
        if num_files < 1:
            return jsonify({"error": "Number of files must be at least 1"}), 400

        response_messages = []  # Store responses for each file

        for i in range(num_files):
            # Generate XML content in memory
            xml_content = create_random_xml_data()
            xml_file = BytesIO(xml_content)  # Create an in-memory file-like object

            # Send the generated XML directly to the Converter API
            response = requests.post(
                'http://127.0.0.1:5001/convert',  # Converter API endpoint
                files={'file': ('file.xml', xml_file, 'application/xml')}
            )

            response_messages.append(response.json())  # Store response for each conversion

            if response.status_code != 200:
                return jsonify({
                    "error": f"Failed to convert XML file {i + 1}",
                    "details": response.json()
                }), 500

        return jsonify({
            "message": f"{num_files} XML files generated and sent successfully.",
            "responses": response_messages  # Return all responses
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(port=5000, debug=True)
