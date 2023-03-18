#!/bin/sh

terraform -chdir=./terraform destroy --var-file=".credentials.tfvars"
