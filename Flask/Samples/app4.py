from flask import *

app=Flask(__name__)


@app.route('/')
def func1():
    return "Welcome to Home page"

@app.route('/guests/<name>/',endpoint='guest')
def userdetails(name):
    return f"hello {name} welcome as guest"

@app.route('/admin/<name>')
def admin(name):
    return f"hello {name} welcome as admin"

@app.route('/user/<user>/<username>')
def user(username,user):
    if user=='admin':
        return redirect(url_for('admin',name=username))
    else:
        return redirect(url_for('guest',name=username))

def func2():
    return 'hello guyyys'

app.add_url_rule('/rule','addurl',func2)

if __name__ == '__main__':
    app.run(debug=True)