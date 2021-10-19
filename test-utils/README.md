# Utils for test ansible configs
## Test teams api
Server for emulating api response after teams registration
```
python3 test_api.py
```
Curl request:
```
curl http://localhost:8080/api/v1/services/teams/info
{
  "teams": [
    {
      "dhcp_end": "10.0.1.253",
      "dhcp_start": "10.0.1.11",
      "ip": "10.0.1.254",
      "mac": "52:54:00:50:99:c1",
      "mode": "nat",
      "name": "team-br-first",
      "netmask": "255.255.255.0",
      "team_name": "first"
    },
    {
      "dhcp_end": "10.0.2.253",
      "dhcp_start": "10.0.2.11",
      "ip": "10.0.2.254",
      "mac": "52:54:00:50:99:c2",
      "mode": "nat",
      "name": "team-br-second",
      "netmask": "255.255.255.0",
      "team_name": "second"
    }
  ]
}
```