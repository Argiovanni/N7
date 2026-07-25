from flask import Flask, render_template, request
import can
import json
import time


app = Flask(__name__)

@app.route("/")
def select_user():
    new_user_button = "New user"
    return render_template('index.html',new_user_button=new_user_button)

@app.route('/submit', methods=['POST'])
def submit():
    if request.method == 'POST':
        name = request.form['name']
    
    # Perform some processing with the form data
    return 'Hello, ' + name + '!'
