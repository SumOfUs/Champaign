# Champaign

[![Circle CI](https://circleci.com/gh/SumOfUs/Champaign/tree/master.svg?style=shield)](https://circleci.com/gh/SumOfUs/Champaign/tree/master) [![Coverage Status](https://coveralls.io/repos/github/SumOfUs/Champaign/badge.svg?branch=master)](https://coveralls.io/github/SumOfUs/Champaign?branch=master) [![Code Climate](https://codeclimate.com/github/SumOfUs/Champaign/badges/gpa.svg)](https://codeclimate.com/github/SumOfUs/Champaign)

Champaign is an open source digital campaigning platform built by [SumOfUs](http://sumofus.org/). It's designed to streamline campaigner workflows creating and iterating on pages, while also providing tools for deep customization of layouts and functionality, all through the web interface. At it's core, Champaign is a CMS to easily create petitions, fundraisers, social-media shares, and surveys, and to record member responses to these action pages. It is also designed to be extensible, allowing developers to contribute new page functionality.

Champaign is also designed with a focus on performance, reliability, maintainability.
- *Performance*: In the SumOfUs production deployment, 95th percentile response times for member-facing pages are 120ms, +/- 20ms.
- *Reliability*: The test suite covers 92% of the ruby code with more than 2300 unit and integration specs.
- *Maintainability*: Champaign code has been guided strongly by the [single responsibility principle](https://en.wikipedia.org/wiki/Single_responsibility_principle) and consequently has skinny controllers, skinny models, and many service classes. The continuous integration also runs code analyzers, including the Rubocop and CodeClimate style checkers.

This is the second digital campaigning CMS developed under direction SumOfUs. The previous system, ActionSweet, still powers several other digital campaigning organizations. Champaign was designed to specifically alleviate issues present in ActionSweet and manifests the lessons learned over 5 years of running online campaigns.

If you're interested in collaborating on the project with us, or have ideas or recommendations, please get in touch!

## Development setup

* Install gem dependencies by running `gem install bundler` and then `bundle install`.
* Install node dependencies by running `npm install`
* Setup your db connection by running `cp config/env.template.yml config/env.yml` and edit
  `config/env.yml` with your development database information.
* Create the development databases: `bundle exec rake db:create`
* Run migrations: `bundle exec rake db:schema:load`
* Run the seed task: `bundle exec rake db:seed`
* Run the test suite to make sure everything's setup correctly: `bundle
  exec rake test`

## Champaign Configuration

Configuration files are under `config/settings` directory. There's one
config file per environment: production, test and development. All keys
defined in these YAML files will be accessible via
`Settings.option_name`.

You can override configuration variables during development by creating
a `config/settings/development.local.yml` file.

## Assets

Champaign is a full Rails app. While it's ready to be deployed out of the box, you will likely want to add css, javascript, images, and translations to your deploy. To that end, Champaign supports loading assets from an external repository, both in development from a local directory and in production by downloading from a Github repository.

## ActionKit Integration

Champaign integrates seamlessly with ActionKit. The integration works
via events that are triggered from Champaign and are then captured by
a separate service: [champaign-ak-processor](https://github.com/SumOfUs/champaign-ak-processor), which in turn
updates ActionKit via its API. Champaign events are delivered using AWS SNS/SQS.

Despite having this external service to communicate with ActionKit,
Champaign still needs to access ActionKit's API directly in a couple of
cases, that's why you'll need to configure AK credentials in order to
run Champaign. You'll be able to do this using [environment variables](config/settings/production.yml)
 in production, or overriding the proper keys in `config/settings.development.local.yml`
for development.

## Braintree & GoCardless integration

Champaign accepts donations by integrating with [Braintree](https://www.braintreepayments.com/) for
credit card, debit card, and Paypal payments, and [GoCardless](https://gocardless.com/) for direct debit. To get these integrations
working you'll have to setup the proper credentials by setting [environment variables](config/settings/production.yml) on
your production environment.

If you use a separate endpoint to fetch your Braintree tokens, you can point to it by updating
the [env.yml](env.yml) with your `BRAINTREE_TOKEN_URL`. By default, Champaign will use its own token
endpoint which could degrade performance, so it's recommended that you use a separate service where
possible.

## Development Setup using Docker

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
