from flask import Flask, jsonify, request
import os
import random
import string
import xml.etree.ElementTree as ET

app = Flask(__name__)

# Define the target folder to store generated XML files
GENERATED_XML_FOLDER = 'xml_files'
os.makedirs(GENERATED_XML_FOLDER, exist_ok=True)

def generate_random_string(length=6):
    """Generate a random string of uppercase letters."""
    return ''.join(random.choices(string.ascii_uppercase, k=length))

def create_random_xml_data():
    """Generate random XML data structure."""
    root = ET.Element('data')

    # Randomly create users, books, or orders
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

    return ET.tostring(root, encoding='unicode')

@app.route('/generate_xml', methods=['POST'])
def generate_xml_file():
    try:
        # Get the number of XML files to generate from the request (default: 1)
        num_files = int(request.form.get('num_files', 1))

        if num_files < 1:
            return jsonify({"error": "Number of files must be at least 1"}), 400

        generated_files = []
        for _ in range(num_files):
            # Generate random XML data
            xml_content = create_random_xml_data()

            # Generate a random filename
            filename = f"file_{generate_random_string()}_{random.randint(1000, 9999)}.xml"
            filepath = os.path.join(GENERATED_XML_FOLDER, filename)

            # Write XML content to file
            with open(filepath, 'w') as f:
                f.write(xml_content)

            generated_files.append(filepath)

        return jsonify({
            "message": f"{num_files} XML files generated successfully.",
            "files": generated_files
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
