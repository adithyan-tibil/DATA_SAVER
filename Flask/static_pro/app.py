from flask import *

app = Flask(__name__)

@app.route('/')
def image():
    return render_template('temp.html', title='carzone')


if __name__ == '__main__':
    app.run(debug=True)
