# Falcon Starter Kit

The repository provides an easy way to spin up the whole infrastructure and install [Falcon](https://systemseed.com/products/falcon) project with the default theme. It helps to begin developing your own projects based on [Falcon](https://systemseed.com/products/falcon) faster.

## Requirements:

 - [Docker](https://docs.docker.com/install)
 - [Docker Compose](https://docs.docker.com/compose/install)
 - [GNU Make](https://www.gnu.org/software/make) - comes with most MacOS & Linux systems out of the box

## How start:

Clone the repository and run `make install` command in the root of the project. That's it. Simple. Cool. We know!

#### Access the project
 
| URL                                    | Name     |
| ---------------------------------------| -------- |
| http://frontend.docker.localhost       | Frontend |
| http://admin.docker.localhost          | Backend  |


#### Command list

- `make install` - installs the whole application locally, including the environment.
- `make up` - spins up the development environment.
- `make stop` - stops the development environment without deleting the Docker containers.
- `make down` - stops the development environment AND deletes the Docker containers.
- `make restart` - restarts the development environment.
- `make drush` - runs drush inside of php container. Example of use: `make drush cr`.
- `make yarn` - runs yarn inside of node.js container. Example of use: `make yarn add lodash`.
- `make logs` - opens console debug mode for fronend application.
- `make exec` - opens terminal inside of the given container. Example of use: `make exec php`.
