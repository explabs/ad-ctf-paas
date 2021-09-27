from flask import Flask, request

app = Flask(__name__)

flag = ""


@app.route("/user", methods=["PUT"])
def user():
    global flag
    if request.method == "PUT":
        data = request.json
        flag = data["password"]
        return f"add user {data['name']}"


@app.route("/check/<route>")
def checker(route):
    if route == "user":
        return flag


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=80)
