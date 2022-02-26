import requests
from checker import Checker

c = Checker()


@c.ping
def ping():
    r = requests.get(f"http://{c.address}:3333/user", timeout=2)
    if r.status_code == 200:
        return 'pong'


@c.put
def put():
    r = requests.post(f"http://{c.address}:3333/user/", json={"name": "test", 'password': c.flag})
    if r.status_code == 200:
        # returns uniq value such as database id
        return r.text


@c.get
def get():
    r = requests.get(f"http://{c.address}:3333/user/{c.uniq_value}")
    if r.status_code == 200:
        # returns flag as string
        return r.text


if __name__ == '__main__':
    c.run()
