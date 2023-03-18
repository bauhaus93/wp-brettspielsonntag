#!/bin/sh

. .env
 ansible-playbook --vault-password-file .vaultpw -i ansible/inventory.py ansible/provisioning/app/main.yml
