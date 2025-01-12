from flask import Flask, url_for

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to the homepage!"

@app.route('/user/<username>')
def profile(username):
    return f"Profile page of {username}"

@app.route('/link')
def link():
    # URL building
    homepage_url = url_for('home')
    profile_url = url_for('profile', username='Alice')
    return f"Homepage: {homepage_url}, Profile: {profile_url}"

if __name__ == "__main__":
    app.run(debug=True)
