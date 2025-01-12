# from flask import Flask
#
# app = Flask(__name__)
#
#
# @app.route('/', methods=['GET'])
# def message():
#     return "Hello World"
#
#
# if __name__ == '__main__':
#     app.run(debug=True)


# from flask import Flask
#
# app = Flask(__name__)
#
#
# @app.route('/home/<name>')
# def home(name):
#     return "hello," + name
#
#
# if __name__ == "__main__":
#     app.run(debug=True)


from flask import Flask

app = Flask(__name__)


@app.route('/user/<username>')
def show_user_profile(username):
    return f"User: {username}"


@app.route('/post/<int:post_id>')
def show_post(post_id):
    return f"Post ID: {post_id}"

if __name__ == "__main__":
    app.run(debug=True)