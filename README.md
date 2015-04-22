# Champaign

Champaign is a digital campaigning platform built by SumOfUs. It is under development and currently offers very little functionality. If you're interested in collaborating on the project with us, have ideas or recommendations, please get in touch! 

## Installation

1. Install Docker - for detailed instructions, go [here](https://docs.docker.com/installation/).
  * If you're using OS X, install Docker and Boot2Docker together via homebrew: `brew install boot2docker`
  * If you're using a Linux system, you can install Docker natively via: `sudo apt-get install docker` or
  similar for RH-based systems.
2. Install Docker-Compose (previously fig) [here](http://docs.docker.com/compose/install/)
3. Clone the project to your local system using git
4. Set up and run the project:
  * `docker-compose build` This will take a few minutes to download the relevant containers and install
  ruby gems.
  * Create the database by issuing `docker-compose run web db:create` and do initial database migrations by issuing `docker-compose run web db:migrate`
  * `docker-compose up` This will start the application running in the docker container.
  * If you are on Linux, you can check that the application is running by visiting localhost with the specified port (at this time,`http://localhost:3000`).
  * If you are on OS X, you will need to retrieve the IP of your Docker vm by running `boot2docker ip`
  on the command line. (On most machines, this seems to be `192.168.59.103`).
  * On OS X, visit `http://boot2docker_ip:port` (or the equivalent result of `boot2docker ip` with port 3000) in your
  browser to see the application running.
