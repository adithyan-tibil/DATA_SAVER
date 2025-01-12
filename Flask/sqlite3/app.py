from flask import *
import sqlite3

database='emp.db'

app=Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/add')
def add():
    return render_template('add.html')

@app.route('/savedetails',methods=['POST','GET'])
def saveDetails():
    msg='empty'
    if request.method=='POST':
        try:
            name = request.form['name']
            email = request.form['email']
            address = request.form['address']
            with sqlite3.connect('emp.db') as con :
                cur = con.cursor()
                cur.execute("INSERT INTO Employees(name,email,address) VALUES(?,?,?)",(name,email,address))
                # con.commit()
                msg = "Employee successfully Added"  
        except:  
            con.rollback()  
            msg = "We can not add the employee to the list"  
        finally:  
            con.close()  
            return render_template("success.html",msg = msg) 

@app.route('/delete')
def delete():
    return render_template('delete.html')

@app.route('/deleterecord',methods=['POST'])
def deleterecord():
    id = request.form['id']
    with sqlite3.connect('emp.db') as con:
        try:
            cur = con.cursor()
            cur.execute('delete from Employees where id=?',id)
            msg='succesfully deleted'
        except:
            msg='id not found or unable to delete'
        finally:
            return render_template('deleted_record.html',msg=msg)            

@app.route('/view')
def view():
    con=sqlite3.connect('emp.db')
    con.row_factory=sqlite3.Row
    cur=con.cursor()
    cur.execute('select * from Employees')
    rows=cur.fetchall()
    return render_template('view.html',rows=rows)



        

if __name__ == "__main__":
    app.run(debug=True)

