from flask import *
from datetime import *
app=Flask(__name__)

app.secret_key="abc"

app.permanent_session_lifetime = timedelta(seconds=20)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login',methods=["GET","POST"])
def login():
    if request.method== "POST":
        session.permanent=True
        session['user']=request.form["user"]
        return redirect(url_for("user"))
    else:
        if 'user' in session:
            return redirect(url_for("user"))
        return render_template("login.html")

@app.route('/user')
def user():
    if 'user' in session:
        user=session["user"]
        return render_template("user.html",user=user)
    return redirect(url_for("login"))

@app.route('/logout')
def logout():
    session.pop('user',None)
    return redirect(url_for('login'))

if __name__ == "__main__":
    app.run(debug=True)