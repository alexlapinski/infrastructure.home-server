# ------------------
# ANSIBLE-MAKEFILE v0.13.0
# Run ansible commands with ease
# ------------------
#
# Copyright (C) 2017 Paul(r)B.r
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# -----------------------------
# Modified by Alex Lapinski <contact@alexlapinski.name>
# https://alexlapinski.name/ansible
# -----------------------------
#

##
# VARIABLES
##
playbook   ?= site
roles_path ?= "roles/"
env        ?= production
mkfile_dir ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

##
# TASKS
##
.PHONY: install
install: ## make install [roles_path=roles/] # Install roles dependencies
	@ansible-galaxy install --roles-path="$(roles_path)" --role-file="requirements.yml" --force

.PHONY: inventory
inventory: ## make inventory [provider=<ec2|gce...>] [env=hosts] # Download dynamic inventory from Ansible's contrib
	@wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/$(provider).py
	@chmod +x $(provider).py
	mv $(provider).py $(env)

.PHONY: lint
lint:
	@env=$(env) ansible-lint "$(playbook).yml"

.PHONY: debug
debug: mandatory-host-param ## make debug host=hostname [env=hosts] [args=<ansible arguments>] # Debug a host's variable
	@env=$(env) ansible -i $(env) $(opts) -m setup $(host)
	@env=$(env) ansible --inventory-file="$(env)" $(opts) --module-name="debug" --args="var=hostvars[inventory_hostname]" $(host)

.PHONY: dry-run
dry-run: ## make dry-run [playbook=setup] [env=hosts] [tag=<ansible tag>] [limit=<ansible host limit>] [args=<ansible-playbook arguments>] # Run a playbook in dry run mode
	@env=$(env) ansible-playbook --inventory-file="$(env)" --diff --check $(opts) "$(playbook).yml"

.PHONY: run
run: ## make run [playbook=setup] [env=hosts] [tag=<ansible tag>] [limit=<ansible host limit>] [args=<ansible-playbook arguments>] # Run a playbook
	@env=$(env) ansible-playbook --inventory-file="$(env)" --diff $(opts) "$(playbook).yml"

.PHONY: run_debug
run_debug: ## make run [playbook=setup] [env=hosts] [tag=<ansible tag>] [limit=<ansible host limit>] [args=<ansible-playbook arguments>] # Run a playbook
	@env=$(env) ansible-playbook -vvvv --inventory-file="$(env)" --diff $(opts) "$(playbook).yml"

group ?=all
.PHONY: list
list: ## make list [group=all] [env=hosts] # List hosts inventory
	@env=$(env) ansible --inventory-file="$(env)" $(group) --list-hosts

.PHONY: facts
facts: ## make facts [group=all] [env=hosts] # List facts for hosts
	@env=$(env) ansible --inventory-file="$(env)" $(group) -m setup

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help