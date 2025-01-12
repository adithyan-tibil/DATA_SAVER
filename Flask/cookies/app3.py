from flask import *

app=Flask(__name__)

# @app.route('/')
# def cookies():
#     resp=make_response('Cookies are Set')
#     resp.set_cookie('username','Arun')
#     return resp


# @app.route('/get_cookie')
# def get_cookie():
#     username = request.cookies
#     return username

@app.route('/')  
def customer():  
   return render_template('customer.html')  

@app.route('/success',methods = ['POST'])  
def success():  
    if request.method == "POST":  
        email = request.form['email']  
        name = request.form['name']  
      
        resp = make_response(render_template('success.html'))  
        resp.set_cookie('email',email,httponly=True) # so if you try to access the cookies using js you wont be able access it
        resp.set_cookie('name',name) 
        return resp  
 
@app.route('/cookies')  
def profile():  
    email = request.cookies.get('email')
    name = request.cookies.get('name') 
    resp = make_response(render_template('cookiesss.html',name = name,email=email))

    # cook=request.cookies
    # resp = make_response(render_template('cookiesss.html',name =cook))  
 
    return resp  

@app.route('/delete_cookies')
def delete_cookies():
    resp = make_response('''<h1>deleted cookies<h1> 
                         <a href='/cookies'>cookies</a>''')
    
    resp.delete_cookie('name')
    resp.delete_cookie('email')
    
    return resp

if __name__ == '__main__':
    app.run(debug=True)