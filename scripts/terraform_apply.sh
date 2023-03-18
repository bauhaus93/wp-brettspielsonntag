#!/bin/sh

terraform -chdir=./terraform apply --var-file=".credentials.tfvars"
