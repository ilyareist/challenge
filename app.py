from flask import Flask, request, jsonify, Response
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from datetime import date, datetime

import os

# Init app
app = Flask(__name__)
app.config.from_pyfile('configs/config.py')
basedir = os.path.abspath(os.path.dirname(__file__))

# Init db
db = SQLAlchemy(app)
# Init ma
ma = Marshmallow(app)


# User Class/Model
class User(db.Model):
    # id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), primary_key=True)
    dateOfBirth = db.Column(db.Date)

    def __init__(self, username, dateOfBirth):
        self.username = username
        self.dateOfBirth = dateOfBirth


# User Schema
class UserSchema(ma.Schema):
    class Meta:
        fields = ('username', 'dateOfBirth')


# Init schema
db.create_all()
user_schema = UserSchema(strict=True)
users_schema = UserSchema(many=True, strict=True)


# Get All Users
# @app.route('/hello', methods=['GET'])
# def get_products():
#     all_products = User.query.all()
#     result = users_schema.dump(all_products)
#     return jsonify(result.data)


# Get a User
@app.route('/hello/<username>', methods=['GET'])
def get_user(username):
    user = User.query.get(username)
    today = date.today()
    birthDay = date(today.year, user.dateOfBirth.month, user.dateOfBirth.day)
    # days = (max(dif1, dif2) - today).days
    days = (today - birthDay).days
    if days < 0 and days != 0:
        today = date(today.year + 1, today.month, today.day)
        days = (today - birthDay).days
    print(days)
    if days == 0:
        response = "Happy birthday"
    else:
        response = "You birthday is in {} day(s)".format(days)
    return jsonify(message="Hello, {}! {}".format(username, response))


# Update or create a User
@app.route('/hello/<username>', methods=['PUT'])
def update_product(username):
    user = User.query.get(username)
    dateOfBirth = datetime.strptime(request.json['dateOfBirth'], '%Y-%m-%d')
    if user:
        user.username = username
        user.dateOfBirth = dateOfBirth
        db.session.commit()

    else:
        new_user = User(username, dateOfBirth)
        db.session.add(new_user)
        db.session.commit()

    return Response(status=204)


# Run Server
if __name__ == '__main__':
    app.run(host='0.0.0.0')
