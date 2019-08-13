# Define here list of available make commands.
.PHONY: default pull up stop down clean exec exec\:wodby exec\:root drush \
prepare install

# Create local environment files.
$(shell cp -n \.\/\.docker\/docker-compose\.override\.default\.yml \.\/\.docker\/docker-compose\.override\.yml)

# If .env file doesn't exist yet - copy it from the default one.
# Then if OS is Linux we change the PHP_TAG:
#  - uncomment all the strings containing 'PHP_TAG'
#  - comment all the strings containing 'PHP_TAG' and '-dev-macos-'
$(shell ! test -e \.env && cp \.env\.default \.env && cp \.env\.default && uname -s | grep -q 'Linux' && sed -i '/PHP_TAG/s/^# //g' \.env && sed -i -E '/PHP_TAG.+-dev-macos-/s/^/# /g' \.env)

include .env

# Define function to highlight messages.
# @see https://gist.github.com/leesei/136b522eb9bb96ba45bd
cyan = \033[38;5;6m
bold = \033[1m
reset = \033[0m
message = @echo "${cyan}${bold}${1}${reset}"

# Define 3 users with different permissions within the container.
# docker-www-data is applicable only for php container.
docker-www-data = docker-compose exec --user=82:82 $(firstword ${1}) time -f"%E" sh -c "$(filter-out $(firstword ${1}), ${1})"
docker-wodby = docker-compose exec $(firstword ${1}) time -f"%E" sh -c "$(filter-out $(firstword ${1}), ${1})"
docker-root = docker-compose exec --user=0:0 $(firstword ${1}) time -f"%E" sh -c "$(filter-out $(firstword ${1}), ${1})"

default: up

pull:
	$(call message,$(PROJECT_NAME): Updating Docker images)
	docker-compose pull

up:
	$(call message,$(PROJECT_NAME): Build and run containers)
	docker-compose up -d --remove-orphans

stop:
	$(call message,$(PROJECT_NAME): Stopping containers)
	docker-compose stop

down:
	$(call message,$(PROJECT_NAME): Removing network & containers)
	docker-compose down -v --remove-orphans

restart:
	@$(MAKE) -s down
	@$(MAKE) -s up

exec:
    # Remove the first argument from the list of make commands.
	$(eval ARGS := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval TARGET := $(firstword $(ARGS)))
	docker-compose exec --user=82:82 $(TARGET) sh

exec\:wodby:
    # Remove the first argument from the list of make commands.
	$(eval ARGS := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval TARGET := $(firstword $(ARGS)))
	docker-compose exec $(TARGET) sh

exec\:root:
    # Remove the first argument from the list of make commands.
	$(eval ARGS := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval TARGET := $(firstword $(ARGS)))
	docker-compose exec --user=0:0 $(TARGET) sh

drush:
    # Remove the first argument from the list of make commands.
	$(eval COMMAND_ARGS := $(filter-out $@,$(MAKECMDGOALS)))
	$(call message,Executing \"drush -r web $(COMMAND_ARGS) --yes\")
	$(call docker-www-data, php drush -r web $(COMMAND_ARGS) --yes)

prepare: | up
    # Prepare composer dependencies.
	$(call message,$(PROJECT_NAME): Installing/updating composer dependencies)
	-$(call docker-wodby, php composer install --no-suggest)

	$(call message,$(PROJECT_NAME): Installing dependencies for React.js application)
	docker-compose run --rm node yarn install

    # Prepare public files folder.
	$(call message,$(PROJECT_NAME): Preparing public files directory)
	$(call docker-wodby, php mkdir -p web/sites/default/files)
	$(call docker-root, php chown -R www-data: web/sites/default/files)
    # Prepare settings.php file.
	$(call message,$(PROJECT_NAME): Making settings.php writable)
	$(call docker-wodby, php chmod 666 web/sites/default/settings.php)

install: | prepare
	$(call message,$(PROJECT_NAME): Installing Drupal)
	sleep 5
    # TODO: Copy file only if it does not exist. Copy from web/modules/contrib/falcon;
	$(call docker-www-data, php curl -o web/sites/development.services.yml https://raw.githubusercontent.com/systemseed/falcon/releases/falcon/settings/development.services.yml)
	$(call docker-www-data, php drush -r web site-install falcon \
		--db-url=mysql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST)/$(DB_NAME) --site-name=$(PROJECT_NAME) --account-pass=admin \
		install_configure_form.enable_update_status_module=NULL --yes)
	$(call message,Congratulations! You installed $(PROJECT_NAME)!)

yarn:
	$(call message,$(PROJECT_NAME): Running Yarn)
	$(eval ARGS := $(filter-out $@,$(MAKECMDGOALS)))
	docker-compose run --rm node yarn $(ARGS)

logs:
	$(call message,$(PROJECT_NAME): Streaming the Next.js application logs)
	docker-compose logs -f node
