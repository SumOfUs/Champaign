# Champaign

Champaign is a digital campaigning platform built by SumOfUs. It is now production ready in its most minimal form! If you're interested in collaborating on the project with us, have ideas or recommendations, please get in touch. 

## Installation

1. Install Docker - for detailed instructions, go [here](https://docs.docker.com/installation/).
  * If you're using OS X, install Docker and Boot2Docker together via homebrew: `brew install boot2docker`
  * If you're using a Linux system, you can install Docker natively via: `sudo apt-get install docker` or
  similar for RH-based systems.

2. Install Docker-Compose (previously fig) [here](http://docs.docker.com/compose/install/)


3. Install VirtualBox [here](https://www.virtualbox.org/wiki/Downloads)
  * to check if you already have it, you can type `VBoxManage` at the command line.

4. Clone the project to your local system using git

5. Set up the docker VM
  * run `boot2docker init` then `boot2docker up`. Add the bash variables output by `boot2docker up` to your `~/.bash_profile` or `~/.bash_rc` and reload the terminal.
  * create a file to hold the web enviroment by running `touch .env.web`.
6. Setup and start Rails
  * `docker-compose build` This will take a few minutes to download the relevant containers and install
  ruby gems.
  * Copy `secrets.yml` to the `config` directory.
  * Run `cp config/env.yml.template config/env.yml`.
  * Update `env.yml` with valid keys.
  * Create the database by issuing `docker-compose run web rake db:create` and load the tables by issuing `docker-compose run web rake db:schema:load`
  * Seed db with liquid templates: `docker-compose run web rake champaign:seed_liquid `
  * `docker-compose up` This will start the application running in the docker container.

7. Check that it's running
  * If you are on Linux, you can check that the application is running by visiting localhost with the specified port (at this time,`http://localhost:3000`).
  * If you are on OS X, you will need to retrieve the IP of your Docker vm by running `boot2docker ip`
  on the command line. (On most machines, this seems to be `192.168.59.103`).
  * On OS X, visit `http://boot2docker_ip:port` (or the equivalent result of `boot2docker ip` with port 3000) in your browser to see the application running.

8. Run the tests
  * `docker-compose run web rspec spec`

## QA

Cross browser QA of member-facing pages has been done with the whiz-bang tech from [Browserstack](https://www.browserstack.com).
