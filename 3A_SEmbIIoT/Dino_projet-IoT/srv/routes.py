from flask import Blueprint, render_template, redirect, url_for, request
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash
from .forms import NewUserForm
from flask import flash
from .models import User
from . import db
import can
import json
import time


main = Blueprint("main", __name__)


@main.route("/")
def index():
    users = User.query.all()
    return render_template("index.html", users=users)


@main.route("/submit", methods=["POST"])  # old/deprecated. to be removed
def submit():
    if request.method == "POST":
        name = request.form["name"]

    # Perform some processing with the form data
    return "Hello, " + name + "!"


@main.route("/user/new", methods=["GET", "POST"])
def create_user():
    form = NewUserForm()

    if form.validate_on_submit():
        username = form.username.data

        # Vérifier unicité
        existing_user = User.query.filter_by(username=username).first()
        if existing_user:
            flash("User already exists", "error")
            return render_template("new_user.html", form=form)

        user = User(
            username=username, password_hash=generate_password_hash(form.password.data)
        )

        db.session.add(user)
        db.session.commit()

        flash("User created successfully", "success")
        return redirect(url_for("main.index"))

    return render_template("new_user.html", form=form)


@main.route("/dashboard")
@login_required
def dashboard():
    return render_template("dashboard.html", user=current_user)


@main.route("/login/<int:user_id>", methods=["GET", "POST"])
def login_user_profile(user_id):
    user = User.query.get_or_404(user_id)

    if request.method == "POST":
        # plus tard : check_password_hash
        login_user(user)
        return redirect(url_for("main.dashboard"))

    return render_template("login.html", selected_user=user)


@main.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for("main.index"))
