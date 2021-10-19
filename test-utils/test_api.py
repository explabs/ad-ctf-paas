from flask import Flask, request

app = Flask(__name__)

flag = dict()


@app.route("/api/v1/services/teams/info")
def get_teams():
    teams = list()
    teams_names = ['first', 'second']
    for i, team_name in enumerate(teams_names, 1):
        teams.append({"team_name": team_name,
                      "name": f"team-br-{team_name}",
                      "ip": f"10.0.{i}.254",
                      "mode": "nat",
                      "netmask": "255.255.255.0",
                      "dhcp_start": f"10.0.{i}.11",
                      "dhcp_end": f"10.0.{i}.253",
                      "mac": f"52:54:00:50:99:c{i}"})
    return {"teams": teams}


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
