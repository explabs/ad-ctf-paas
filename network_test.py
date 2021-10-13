import jinja2

with open('network.xml.j2') as file_:
    template = jinja2.Template(file_.read())

for i in range(1, 3):
    network = {
        "name": f"virtbr-team{i}",
        "bridge": f'team-br{i}',
        "ip": f"10.0.{i}.254",
        "mode": "nat",
        "netmask": "255.255.255.0",
        "dhcp_start": f"10.0.{i}.11",
        "dhcp_end": f"10.0.{i}.253",
    }
    rendered_template = template.render(item=network)
    print(rendered_template)
    with open(f'team{i}.xml', "w") as f:
        f.write(rendered_template)

# virsh net-create network.xml
# iptables -I FORWARD -i tun+ -j ACCEPT
# iptables -I FORWARD -i tun+ -o team-br+ -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -I FORWARD -i team-br+ -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o tun+ -j ACCEPT


# iptables -I FORWARD -i tun+ -j ACCEPT
# iptables -I FORWARD -i tun+ -o team1-br -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -I FORWARD -i team1-br -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o tun+ -j ACCEPT