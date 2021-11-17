# Utils for testing
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

## Validator
Run script to check syntax and file existence
```
python3 test-utils/validator.py
```
### Usage:
```
validator.py [-h] [--dev] [--debug] [--news] [--api API] [--script SCRIPT] [--mode mode] [--girl]
```
### Optional arguments:
```
-h, --help       show this help message and exit
--dev            dev mode for local tests (default: False)
--debug          debug mod for errors showing (default: False)
--news           print news from news file (default: False)
--api API        set api dir path if needed (default: admin-node/ad-ctf-paas-api/)
--script SCRIPT  set script dir path if needed (default: admin-node/ad-ctf-paas-api/scripts/)
--mode mode      defines the game mode (default: defence)
--girl           makes info text a little bit cuter (default: False)
```