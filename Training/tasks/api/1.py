from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/ss', methods=['GET'])
def print_values():
    # Retrieve header values
    college_id_header = request.headers.get('college-id')
    authorization_header = request.headers.get('Authorization')

    # Print the retrieved values (for demonstration purposes)
    print(f"college-id: {college_id_header}")
    print(f"Authorization: {authorization_header}")

    # Construct a response JSON (optional)
    response_data = {
        "college_id": college_id_header,
        "authorization": request.headers
    }

    return jsonify(response_data), 200

if __name__ == '__main__':
    app.run(debug=True)
#







    # try:
    #     student = Student.query.get(std_id)
    #     if not student:
    #         return jsonify({'error': 'student id not found'}), 404
    #     data = request.form
    #     required_fields = ('std_name', 'std_address', 'std_year', 'std_cgp', 'std_dept')
    #     for fields in required_fields:
    #         if fields in data:
    #             student.fields = data[fields]
    #             # student.std_address = data['std_address']
    #             # student.std_year = data['std_year']
    #             # student.std_cgp = float(data['std_cgp'])
    #             # student.std_dept = data['std_dept']
    #     db.session.commit()
    #     return jsonify({'message': 'Student info updated'}), 200




# from abc import ABC, abstractmethod
#
# class Vehicle(ABC):
#     @abstractmethod
#     def start_engine(self):
#         pass

# class Car():
#     def start_engine(self):
#         print("Car engine started")
#
# car = Car()
# car.start_engine()  # Output: Car engine started



# from abc import ABC, abstractmethod
#
# class Vehicle(ABC):
#     @abstractmethod
#     def start_engine(self):
#         pass

# class Car():
#     def start_engine(self):
#         print("Car engine started")

# class Motorcycle():
#     def start_engine(self):
#         print("Motorcycle engine started")

# # def start_any_vehicle(vehicle):
# #     vehicle.start_engine()

# car = Car()
# bike = Motorcycle()

# car.start_engine()
# bike.start_engine()













