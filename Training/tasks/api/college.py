from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:tibil123@localhost:5432/api'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Models
class Student(db.Model):
    std_id = db.Column(db.String(50), primary_key=True)
    std_name = db.Column(db.String(100), nullable=False)
    std_address = db.Column(db.String(200), nullable=False)
    std_year = db.Column(db.String(10), nullable=False)
    std_cgp = db.Column(db.Float, nullable=False)
    std_dept = db.Column(db.String(100), nullable=False)

# class Professor(db.Model):
#     id = db.Column(db.Integer, primary_key=True)
#     prof_id = db.Column(db.String(50), nullable=False, unique=True)
#     prof_name = db.Column(db.String(100), nullable=False)
#     prof_class = db.Column(db.String(100), nullable=False)
#     prof_dept = db.Column(db.String(100), nullable=False)

with app.app_context():
    db.create_all()

# Constants
VALID_COLLEGE_IDS = {'CLG_001', 'CLG_002', 'CLG_003'}

# Middleware for college_id validation
@app.before_request
def validate_college_id():
    college_id = request.headers.get('college_id')
    if college_id not in VALID_COLLEGE_IDS:
        return jsonify({'error': 'invalid college_id'}), 400

# Students API
@app.route('/students', methods=['POST'])
def create_student():
    data = request.get_json()
    new_student = Student(
        std_id=data['std_id'],
        std_name=data['std_name'],
        std_address=data['std_address'],
        std_year=data['std_year'],
        std_cgp=data['std_cgp'],
        std_dept=data['std_dept']
    )
    db.session.add(new_student)
    db.session.commit()
    return jsonify({'message': 'Student created successfully'}), 201

# @app.route('/students', methods=['GET'])
# def get_students():
#     students = Student.query.all()
#     return jsonify([{
#         'std_id': student.std_id,
#         'std_name': student.std_name,
#         'std_address': student.std_address,
#         'std_year': student.std_year,
#         'std_cgp': student.std_cgp,
#         'std_dept': student.std_dept
#     } for student in students])
#
@app.route('/students/<std_id>', methods=['GET'])
def get_student(std_id):
    student = Student.query.filter_by(std_id=std_id).first_or_404()
    return jsonify({
        'std_id': student.std_id,
        'std_name': student.std_name,
        'std_address': student.std_address,
        'std_year': student.std_year,
        'std_cgp': student.std_cgp,
        'std_dept': student.std_dept
    })
#
# @app.route('/students/<std_id>', methods=['PUT'])
# def update_student(std_id):
#     data = request.get_json()
#     student = Student.query.filter_by(std_id=std_id).first_or_404()
#     student.std_name = data['std_name']
#     student.std_address = data['std_address']
#     student.std_year = data['std_year']
#     student.std_cgp = data['std_cgp']
#     student.std_dept = data['std_dept']
#     db.session.commit()
#     return jsonify({'message': 'Student updated successfully'})
#
# @app.route('/students/<std_id>', methods=['DELETE'])
# def delete_student(std_id):
#     student = Student.query.filter_by(std_id=std_id).first_or_404()
#     db.session.delete(student)
#     db.session.commit()
#     return jsonify({'message': 'Student deleted successfully'})

# # Professors API
# @app.route('/professors', methods=['POST'])
# def create_professor():
#     data = request.get_json()
#     new_professor = Professor(
#         prof_id=data['prof_id'],
#         prof_name=data['prof_name'],
#         prof_class=data['prof_class'],
#         prof_dept=data['prof_dept']
#     )
#     db.session.add(new_professor)
#     db.session.commit()
#     return jsonify({'message': 'Professor created successfully'}), 201
#
# @app.route('/professors', methods=['GET'])
# def get_professors():
#     professors = Professor.query.all()
#     return jsonify([{
#         'prof_id': professor.prof_id,
#         'prof_name': professor.prof_name,
#         'prof_class': professor.prof_class,
# #         'prof_dept': professor.prof_dept
#     } for professor in professors])
#
# @app.route('/professors/<prof_id>', methods=['GET'])
# def get_professor(prof_id):
#     professor = Professor.query.filter_by(prof_id=prof_id).first_or_404()
#     return jsonify({
#         'prof_id': professor.prof_id,
#         'prof_name': professor.prof_name,
#         'prof_class': professor.prof_class,
#         'prof_dept': professor.prof_dept
#     })
#
# @app.route('/professors/<prof_id>', methods=['PUT'])
# def update_professor(prof_id):
#     data = request.get_json()
#     professor = Professor.query.filter_by(prof_id=prof_id).first_or_404()
#     professor.prof_name = data['prof_name']
#     professor.prof_class = data['prof_class']
#     professor.prof_dept = data['prof_dept']
#     db.session.commit()
#     return jsonify({'message': 'Professor updated successfully'})

# @app.route('/professors/<prof_id>', methods=['DELETE'])
# def delete_professor(prof_id):
#     professor = Professor.query.filter_by(prof_id=prof_id).first_or_404()
#     db.session.delete(professor)
#     db.session.commit()
#     return jsonify({'message': 'Professor deleted successfully'})

if __name__ == '__main__':
    app.run(debug=True)


















# from flask import Flask, request, jsonify
# from flask_sqlalchemy import SQLAlchemy
#
# app = Flask(__name__)
# app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:tibil123@localhost:5432/api'
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# db = SQLAlchemy(app)
#
# # Models
# class Student(db.Model):
#     std_id = db.Column(db.String(50), primary_key=True)
#     std_name = db.Column(db.String(100), nullable=False)
#     std_address = db.Column(db.String(200), nullable=False)
#     std_year = db.Column(db.String(10), nullable=False)
#     std_cgp = db.Column(db.Float, nullable=False)
#     std_dept = db.Column(db.String(100), nullable=False)
#
# # class Professor(db.Model):
# #     id = db.Column(db.Integer, primary_key=True)
# #     prof_id = db.Column(db.String(50), nullable=False, unique=True)
# #     prof_name = db.Column(db.String(100), nullable=False)
# #     prof_class = db.Column(db.String(100), nullable=False)
# #     prof_dept = db.Column(db.String(100), nullable=False)
# with app.app_context():
#     db.create_all()
#
# # Constants
# VALID_COLLEGE_IDS = {'CLG_001', 'CLG_002', 'CLG_003'}
#
# # Middleware for college_id validation
# @app.before_request
# def validate_college_id():
#     college_id = request.headers.get('college_id')
#     if college_id not in VALID_COLLEGE_IDS:
#         return False,jsonify({'error':'invalid college_id'}),400
# # Students API
# @app.route('/students', methods=['POST'])
# def create_student():
#     data = request.form
#     new_student = Student(
#         std_id=data['std_id'],
#         std_name=data['std_name'],
#         std_address=data['std_address'],
#         std_year=data['std_year'],
#         std_cgp=data['std_cgp'],
#         std_dept=data['std_dept']
#     )
#     db.session.add(new_student)
#     db.session.commit()
#     return jsonify({'message': 'Student created successfully'}), 200
#
# # @app.route('/students', methods=['GET'])
# # def get_students():
# #     students = Student.query.all()
# #     return jsonify([{
# #         'std_id': student.std_id,
# #         'std_name': student.std_name,
# #         'std_address': student.std_address,
# #         'std_year': student.std_year,
# #         'std_cgp': student.std_cgp,
# #         'std_dept': student.std_dept
# #     } for student in students])
# #
# # @app.route('/students/<std_id>', methods=['GET'])
# # def get_student(std_id):
# #     student = Student.query.filter_by(std_id=std_id).first_or_404()
# #     return jsonify({
# #         'std_id': student.std_id,
# #         'std_name': student.std_name,
# #         'std_address': student.std_address,
# #         'std_year': student.std_year,
# #         'std_cgp': student.std_cgp,
# #         'std_dept': student.std_dept
# #     })
# #
# # @app.route('/students/<std_id>', methods=['PUT'])
# # def update_student(std_id):
# #     data = request.form
# #     student = Student.query.filter_by(std_id=std_id).first_or_404()
# #     student.std_name = data['std_name']
# #     student.std_address = data['std_address']
# #     student.std_year = data['std_year']
# #     student.std_cgp = data['std_cgp']
# #     student.std_dept = data['std_dept']
# #     db.session.commit()
# #     return jsonify({'message': 'Student updated successfully'})
# #
# # @app.route('/students/<std_id>', methods=['DELETE'])
# # def delete_student(std_id):
# #     student = Student.query.filter_by(std_id=std_id).first_or_404()
# #     db.session.delete(student)
# #     db.session.commit()
# #     return jsonify({'message': 'Student deleted successfully'})
#
# # # Professors API
# # @app.route('/professors', methods=['POST'])
# # def create_professor():
# #     data = request.form
# #     new_professor = Professor(
# #         prof_id=data['prof_id'],
# #         prof_name=data['prof_name'],
# #         prof_class=data['prof_class'],
# #         prof_dept=data['prof_dept']
# #     )
# #     db.session.add(new_professor)
# #     db.session.commit()
# #     return jsonify({'message': 'Professor created successfully'}), 201
# #
# # @app.route('/professors', methods=['GET'])
# # def get_professors():
# #     professors = Professor.query.all()
# #     return jsonify([{
# #         'prof_id': professor.prof_id,
# #         'prof_name': professor.prof_name,
# #         'prof_class': professor.prof_class,
# # #         'prof_dept': professor.prof_dept
# #     } for professor in professors])
# #
# # @app.route('/professors/<prof_id>', methods=['GET'])
# # def get_professor(prof_id):
# #     professor = Professor.query.filter_by(prof_id=prof_id).first_or_404()
# #     return jsonify({
# #         'prof_id': professor.prof_id,
# #         'prof_name': professor.prof_name,
# #         'prof_class': professor.prof_class,
# #         'prof_dept': professor.prof_dept
# #     })
# #
# # @app.route('/professors/<prof_id>', methods=['PUT'])
# # def update_professor(prof_id):
# #     data = request.form
# #     professor = Professor.query.filter_by(prof_id=prof_id).first_or_404()
# #     professor.prof_name = data['prof_name']
# #     professor.prof_class = data['prof_class']
# #     professor.prof_dept = data['prof_dept']
# #     db.session.commit()
# #     return jsonify({'message': 'Professor updated successfully'})
#
# # @app.route('/professors/<prof_id>', methods=['DELETE'])
# # def delete_professor(prof_id):
# #     professor = Professor.query.filter_by(prof_id=prof_id).first_or_404()
# #     db.session.delete(professor)
# #     db.session.commit()
# #     return jsonify({'message': 'Professor deleted successfully'})
#
# if __name__ == '__main__':
#     app.run(debug=True)
