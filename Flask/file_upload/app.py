from flask import *
import os

app = Flask(__name__)

app.secret_key='boom'

app.config['UPLOAD_FOLDER'] = os.path.join(os.getcwd(), 'uploads')
app.config['MAX_CONTENT_LENGTH'] = 1 * 1024 * 1024

@app.route('/')
def upload():
    return render_template("file_upload_form.html")

@app.route('/success', methods=['POST'])
def success():
    if request.method == 'POST':
        f = request.files['file']
        
        # folder exist checking if not creates one 
        if not os.path.exists(app.config['UPLOAD_FOLDER']):
            os.makedirs(app.config['UPLOAD_FOLDER'])
        
        f.seek(0)
        
        # creating path to save file
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], f.filename)
        
        f.save(file_path)
        
        return render_template("success.html", name=f.filename)

@app.errorhandler(413)
def file_too_large(e):
    flash('File is too large! Maximum size allowed is 2MB.')
    return redirect(url_for('upload'))

if __name__ == '__main__':
    app.run(debug=True)





# from flask import *  
# app = Flask(__name__)  
 
# @app.route('/')  
# def upload():  
#     return render_template("file_upload_form.html")  
 
# @app.route('/success', methods = ['POST'])  
# def success():  
#     if request.method == 'POST':  
#         f = request.files['file']  
#         f.save(f.filename)  
#         return render_template("success.html", name = f.filename)  
  
# if __name__ == '__main__':  
#     app.run(debug = True)