from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    items = ['Apples', 'Bananas', 'Cherries']
    return render_template('temp.html', title="Home Page", username="John", items=items)

if __name__ == '__main__':
    app.run(debug=True)
