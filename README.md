# Champaign

[![Circle CI](https://circleci.com/gh/SumOfUs/Champaign/tree/master.svg?style=shield)](https://circleci.com/gh/SumOfUs/Champaign/tree/master) [![Coverage Status](https://coveralls.io/repos/github/SumOfUs/Champaign/badge.svg?branch=master)](https://coveralls.io/github/SumOfUs/Champaign?branch=master) [![Code Climate](https://codeclimate.com/github/SumOfUs/Champaign/badges/gpa.svg)](https://codeclimate.com/github/SumOfUs/Champaign)

Champaign is an open source digital campaigning platform built by [SumOfUs](http://sumofus.org/). It's designed to streamline campaigner workflows creating and iterating on pages, while also providing tools for deep customization of layouts and functionality, all through the web interface. At it's core, Champaign is a CMS to easily create petitions, fundraisers, social-media shares, and surveys, and to record member responses to these action pages. It is also designed to be extensible, allowing developers to contribute new page functionality.

Champaign is also designed with a focus on performance, reliability, maintainability.
- *Performance*: In the SumOfUs production deployment, 95th percentile response times for member-facing pages are 120ms, +/- 20ms.
- *Reliability*: The test suite covers 92% of the ruby code with more than 3000 unit and integration specs.
- *Maintainability*: Champaign code has been guided strongly by the [single responsibility principle](https://en.wikipedia.org/wiki/Single_responsibility_principle) and consequently has skinny controllers, skinny models, and many service classes. The continuous integration also runs code analyzers, including the Rubocop and CodeClimate style checkers.

This is the second digital campaigning CMS developed under direction SumOfUs. The previous system, ActionSweet, still powers several other digital campaigning organizations. Champaign was designed to specifically alleviate issues present in ActionSweet and manifests the lessons learned over 5 years of running online campaigns.

If you're interested in collaborating on the project with us, or have ideas or recommendations, please get in touch!

## Development setup

* Install gem dependencies by running `gem install bundler` and then `bundle install`.
* Install node dependencies by running `yarn`
* Setup your db connection by running `cp config/env.template.yml config/env.yml` and edit
  `config/env.yml` with your development database information.
* Create the development databases: `bundle exec rake db:create`
* Run migrations: `bundle exec rake db:schema:load`
* Run the seed task: `bundle exec rake db:seed`
* Seed the database with liquid layouts: `bundle exec rake champaign:seed_liquid`
* Seed the database with tags and languages from your ActionKit integration: `bundle exec rake action_kit:seed_tags` and `bundle exec rake action_kit:seed_languages`
* Run the test suite to make sure everything's setup correctly: `bundle
  exec rake spec`

## Champaign Configuration

Configuration files are under `config/settings` directory. There's one
config file per environment: production, test and development. All keys
defined in these YAML files will be accessible via
`Settings.option_name`.

You can override configuration variables during development by creating
a `config/settings/development.local.yml` file.

## Vendor theme and overrides

Champaign is a full Rails app. While it's ready to be deployed out of the box,
you will likely want to customise its styles, images, and translations.
To that end,Champaign has a `vendor/theme` folder where you can add,
override, or customise translation strings, layouts/partials, and images.

## ActionKit Integration

Champaign integrates seamlessly with ActionKit. The integration works
via events that are triggered from Champaign and are then captured by
a separate service: [champaign-ak-processor](https://github.com/SumOfUs/champaign-ak-processor), which in turn
updates ActionKit via its API. Champaign events are delivered using AWS SQS.

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

You can run the required Postgres and Redis databases on Docker using docker-compose. We suggest you run the Rails application on host since the default Dockerfile is a production file missing some test / development dependencies.

Simply install Docker and Compose, and issue `docker-compose up` to run your redis and postgres database. Port mapping will map the container ports to the databases' expected (default) ports on host. 
