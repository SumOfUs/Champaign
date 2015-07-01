require 'bunny'

# Right now, this class is simply a copy of the class in `config/initializers/message_queue.rb`,
# looking for a quality way around DRY with this but for the moment we'll leave it as is.
class MessageQueue
  # Store our connection in a class-level variable so
  # connections are persistent while the application is alive.
  @@connection = nil

  def get_connection
    if @@connection
      @@connection
    else
      # 'rabbitmq' is in our host file as the connecting host for
      # our RabbitMQ service thanks to our Docker configuration.
      @@connection = Bunny.new host: 'rabbitmq'
      @@connection.start

      # Need to have a bunch more stuff here about connecting to channels.

      # Return the connection
      @@connection
    end
  end
end
