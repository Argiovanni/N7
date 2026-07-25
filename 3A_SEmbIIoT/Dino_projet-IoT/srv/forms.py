from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired, Length, EqualTo


class NewUserForm(FlaskForm):
    username = StringField(
        "Username", validators=[DataRequired(), Length(min=2, max=64)]
    )

    password = PasswordField("Password", validators=[DataRequired(), Length(min=4)])

    confirm_password = PasswordField(
        "Confirm password",
        validators=[
            DataRequired(),
            EqualTo("password", message="Passwords must match"),
        ],
    )

    submit = SubmitField("Create user")
