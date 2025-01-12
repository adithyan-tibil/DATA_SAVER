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

with app.app_context():
    db.create_all()

@app.before_request
def validate_id_header():
    college_id_header = request.headers.get('college-id')
    if college_id_header not in ('CLG_001','CLG_002','CLG_003'):
        return jsonify({"error": "access denied for this id"}), 401


# Students API
@app.route('/students', methods=['POST'])
def create_student():
    validation_response = validate_id_header()
    if validation_response:
        return validation_response
    try:
        data = request.form
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
        return jsonify({'message': 'Student data added successfully'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500




if __name__ == '__main__':
    app.run(debug=True)
