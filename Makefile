.PHONY: setup requirements

inventory.yml:
	@cp example.inventory.yml inventory.yml
	@printf "\x1B[01;93m✔ inventory.yml file created\n\x1B[0m"

requirements:
	@ansible-galaxy install -r requirements.yml
	@printf "\x1B[01;93m✔ Galaxy collections installed\n\x1B[0m"

setup: inventory.yml requirements
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"
