# Falcon Starter Kit

  The repository provides us easy way to install [Falcon](https://systemseed.com/products/falcon) 
project with default theme. This helps us to quickly begin developing our own project based on [Falcon](https://systemseed.com/products/falcon).

## Requirements:

 - Docker
 - Docker Compose
 - GNU Make 

## How use:

  Download the repo and run `make install` command in root project dir.
  
#### Access applications
 
| URL                                     | Name                |
| ----------------------------------------| ------------------- |
| http://app.docker.localhost             | ReactJS application |
| http://falcon.docker.localhost          | Drupal 8            |


#### Command list

- `make install` - installs the whole application locally.
- `make up` - runs the application.
- `make stop` - pauses the application.
- `make down` - completely stops the application and removes docker containers.
- `make restart` - restarts the application containers.
- `make drush` - runs drush inside of php container. Example of use: `make drush cr`.
- `make yarn` - runs yarn inside of node container. Example of use: `make yarn add lodash`.
- `make logs` - opens console debug mode for fronend application.
- `make exec` - executes particular container. Example of use: `make exec php`.
