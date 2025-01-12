from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

# app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get("POSTGRES_URL")
# print("URL", os.environ.get("POSTGRES_URL"))

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:root@db:5432/api'

db = SQLAlchemy(app)  # This line initializes the SQLAlchemy object and binds it to your Flask app


class Student(db.Model):
    std_id = db.Column(db.String(50), primary_key=True)
    std_name = db.Column(db.String(100), nullable=False)
    std_address = db.Column(db.String(200), nullable=False)
    std_year = db.Column(db.String(10), nullable=False)
    std_cgp = db.Column(db.Float, nullable=False)
    std_dept = db.Column(db.String(100), nullable=False)


class Professors(db.Model):
    pro_id = db.Column(db.String(50), primary_key=True)
    pro_name = db.Column(db.String(100), nullable=False)
    pro_year = db.Column(db.String(10), nullable=False)
    pro_dept = db.Column(db.String(100), nullable=False)


with app.app_context():
    db.create_all()


def validate_id_header():
    college_id_header = request.headers.get('college-id')
    if 'college-id' not in request.headers:
        return jsonify({'error': 'mentioned wrong key'}), 400
    elif college_id_header not in ('CLG_001', 'CLG_002', 'CLG_003'):
        return jsonify({"error": "access denied for this id"}), 401


#                                             --------STUDENT----------

@app.route('/students', methods=['POST'])
def create_student():
    validation_response = validate_id_header()
    if validation_response:
        return validation_response
    try:
        data = request.form
        required_fields = ('std_id', 'std_name', 'std_address', 'std_year', 'std_cgp', 'std_dept')
        missing_fields = [fields for fields in required_fields if fields not in data]
        if missing_fields:
            return jsonify({'The required field are missing': missing_fields}), 400
        new_student = Student(
            std_id=data['std_id'],
            std_name=data['std_name'],
            std_address=data['std_address'],
            std_year=data['std_year'],
            std_cgp=float(data['std_cgp']),
            std_dept=data['std_dept']
        )
        db.session.add(new_student)
        db.session.commit()
        return jsonify({'message': 'Student data added successfully'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/students', methods=['GET'])
def get_students():
    validation_response = validate_id_header()
    if validation_response:
        return validation_response
    try:
        data = Student.query.all()
        return jsonify([{
            'std_id': stu.std_id,
            'std_name': stu.std_name,
            'std_address': stu.std_address,
            'std_year': stu.std_year,
            'std_cgp': stu.std_cgp,
            'std_dept': stu.std_dept
        } for stu in data])
    except Exception as e:
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/students/<std_id>', methods=['GET'])
def get_specific_student(std_id):
    validation_response = validate_id_header()
    if validation_response:
        return validation_response
    try:
        stu = Student.query.get(std_id)
        if not stu:
            return jsonify({'error': 'Student id not found'}), 404
        return jsonify({
            'std_id': stu.std_id,
            'std_name': stu.std_name,
            'std_address': stu.std_address,
            'std_year': stu.std_year,
            'std_cgp': stu.std_cgp,
            'std_dept': stu.std_dept
        })
    except Exception as e:
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/students/<std_id>', methods=['DELETE'])
def del_specific_stu_data(std_id):
    validation_response = validate_id_header()
    if validation_response:
        return validation_response

    try:
        student = Student.query.get(std_id)
        if not student:
            return jsonify({'error': 'Student id not found'}), 404
        db.session.delete(student)
        db.session.commit()
        return jsonify({'message': 'Student deleted successfully'}), 201
    except Exception as e:
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/students/<std_id>', methods=['PUT'])
def edit_particular_student(std_id):
    validation_response = validate_id_header()
    if validation_response:
        return validation_response
    try:
        student = Student.query.get(std_id)
        if not student:
            return jsonify({'error': 'student id not found'}), 404
        data = request.form
        required_fields = ('std_name', 'std_address', 'std_year', 'std_cgp', 'std_dept')
        missing_fields = [fields for fields in required_fields if fields not in data]
        if missing_fields:
            return jsonify({'The required field are missing': missing_fields}), 400
        student.std_name = data['std_name']
        student.std_address = data['std_address']
        student.std_year = data['std_year']
        student.std_cgp = float(data['std_cgp'])
        student.std_dept = data['std_dept']
        db.session.commit()
        return jsonify({'message': 'Student updated successfully'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/students/<std_id>', methods=['PATCH'])
def update_specific_data_in_student(std_id):
    validation_response = validate_id_header()
    if validation_response:
        return validation_response

    try:
        student = Student.query.get(std_id)
        if not student:
            return jsonify({'error': 'student id not found'}), 404
        data = request.form
        if not data:
            return jsonify({'error': 'nothing to update'}), 400
        if 'std_name' in data:
            student.std_name = data['std_name']
        if 'std_address' in data:
            student.std_address = data['std_address']
        if 'std_year' in data:
            student.std_year = data['std_year']
        if 'std_cgp' in data:
            student.std_cgp = float(data['std_cgp'])
        if 'std_dept' in data:
            student.std_dept = data['std_dept']
        db.session.commit()
        return jsonify({'message': 'Student info updated'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


#                                     -----------PROFESSOR-------------

@app.route('/professor', methods=['POST'])
def create_professors():
    validate_response = validate_id_header()
    if validate_response:
        return validate_response

    try:
        data = request.form
        required_fields = ('pro_id', 'pro_name', 'pro_year', 'pro_dept')
        missing_fields = [fields for fields in required_fields if fields not in data]
        if missing_fields:
            return jsonify({'error : missing the required fields': missing_fields}), 404
        new_professor = Professors(
            pro_id=data['pro_id'],
            pro_name=data['pro_name'],
            pro_year=data['pro_year'],
            pro_dept=data['pro_dept']
        )
        db.session.add(new_professor)
        db.session.commit()
        return jsonify({'message': 'professor data added successfully'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/professor', methods=['GET'])
def view_professor():
    validation_response = validate_id_header()
    if validation_response:
        return validation_response

    try:
        data = Professors.query.all()
        return jsonify([{
            'pro_id': pro.pro_id,
            'pro_name': pro.pro_name,
            'pro_year': pro.pro_year,
            'pro_dept': pro.pro_dept
        } for pro in data]), 200
    except Exception as e:
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/professor/<pro_id>', methods=['GET'])
def view_particular_professor(pro_id):
    validation_response = validate_id_header()
    if validation_response:
        return validation_response

    try:
        pro = Professors.query.get(pro_id)
        if not pro:
            return jsonify({'error': 'pro_id not found'})
        return jsonify({
            'pro_id': pro.pro_id,
            'pro_name': pro.pro_name,
            'pro_year': pro.pro_year,
            'pro_dept': pro.pro_dept
        }), 200
    except Exception as e:
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/professor/<pro_id>', methods=['DELETE'])
def del_professor(pro_id):
    validation_response = validate_id_header()
    if validation_response:
        return validation_response
    try:
        pro = Professors.query.get(pro_id)
        if not pro:
            return jsonify({'error': 'pro_id not found'}), 404
        db.session.delete(pro)
        db.session.commit()
        return jsonify({'message': 'professor removed successfully'}), 200
    except Exception as e:
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/professor/<pro_id>', methods=['PATCH'])
def update_professor(pro_id):
    validation_response = validate_id_header()
    if validation_response:
        return validation_response
    try:
        pro = Professors.query.get(pro_id)
        if not pro:
            return jsonify({'error': 'professor id not found'}), 404
        data = request.form
        if not data:
            return jsonify({'error': 'nothing to update'}), 400

        if 'pro_id' in data:
            pro.pro_id = data['pro_id']
        if 'pro_name' in data:
            pro.pro_name = data['pro_name']
        if 'pro_year' in data:
            pro.pro_year = data['pro_year']
        if 'pro_dept' in data:
            pro.pro_dept = data['pro_dept']

        db.session.commit()
        return jsonify({'message': 'Professor data updated successfully'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'server error', 'errortype': str(e)}), 500


@app.route('/professor/<pro_id>', methods=['PUT'])
def updating_entire_data(pro_id):
    validate_response = validate_id_header()
    if validate_response:
        return validate_response

    try:
        data = request.form
        required_fields = ('pro_id', 'pro_name', 'pro_year', 'pro_dept')
        missing_fields = [fields for fields in required_fields if fields not in data]
        if missing_fields:
            return jsonify({'error - missing required fields': missing_fields}), 400
        pro = Professors.query.get(pro_id)
        if not pro:
            return jsonify({'error': 'professor id not found'}), 404
        pro.pro_id = data['pro_id']
        pro.pro_name = data['pro_name']
        pro.pro_year = data['pro_year']
        pro.pro_dept = data['pro_dept']

        db.session.commit()
        return jsonify({'message': 'Professor data updated successfully'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'server error', "": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, port=8000)
