#!/usr/bin/env python3

import argparse
import json
import sys


def parse_args():
    parser = argparse.ArgumentParser(
        description="Creates dynamic ansible inventory from a Vagrantfile"
    )
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--host", action="store_true")
    parser.add_argument(
        "--file",
        metavar="FILE",
        help="The terraform.tfstate file from which to create an ansible inventory",
        default=f"terraform/terraform.tfstate",
    )
    return parser.parse_args(sys.argv[1:])


def get_group_variables():
    return {
        "ansible_user": "root",
        "ansible_ssh_private_key_file": "{{ lookup('env', 'ANSIBLE_SSH_KEY_FILE') }}",
        "ansible_ssh_port": "22",
    }


def parse_tfstate(filename: str):
    ips = []
    with open(filename, "r", encoding="utf-8") as f:
        for line in f.readlines():
            if '"ipv4_address"' in line:
                ips.append(line.split(":")[-1].strip().strip(",").strip('"'))
    return {"app": ips}


def create_inventory(file_path: str):
    terraform_inventory = parse_tfstate(file_path)
    inventory = {
        "all": {"hosts": [], "vars": get_group_variables()},
        "_meta": {"hostvars": {}},
    }

    for (group, hosts) in terraform_inventory.items():
        if group not in inventory:
            inventory[group] = {"hosts": [], "vars": {}}
        for host in hosts:
            if host not in inventory[group]["hosts"]:
                inventory[group]["hosts"].append(host)
            if host not in inventory["all"]["hosts"]:
                inventory["all"]["hosts"].append(host)

    return inventory


def main():
    args = parse_args()
    if args.host:
        print(json.dumps(get_group_variables()))
    else:
        print(json.dumps(create_inventory(args.file)))


if __name__ == "__main__":
    main()
