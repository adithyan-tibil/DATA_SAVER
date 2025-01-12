from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('home.html')

@app.route('/submit', methods=['POST'])
def submit():
    name = request.form['name']
    email = request.form.get('email')
    method = request.method
    
    return f"Received {method} request. Name: {name}, Email: {email}"

if __name__ == '__main__':
    app.run(debug=True)
