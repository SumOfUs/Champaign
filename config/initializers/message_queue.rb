require 'bunny'

class MessageQueue
  # Store our connection in a class-level variable so
  # connections are persistent while the application is alive.
  class_attribute :connection

  def get_connection
    if MessageQueue.connection
      MessageQueue.connection
    else
      # 'rabbitmq' is in our host file as the connecting host for
      # our RabbitMQ service thanks to our Docker configuration.
      MessageQueue.connection = Bunny.new host: 'rabbitmq'
      MessageQueue.connection.start

      # Need to have a bunch more stuff here about connecting to channels.

      # Return the connection
      MessageQueue.connection
    end
  end
end
