require_relative '../lib/message_queue'

class QueueChannelFactory
  # This class is designed to make it easy for individual listeners to the champaign
  # queue to access the necessary connections to subscribe to those channels simply.
  # All of the methods are designed to act as singletons, since they'll be called
  # often and we don't want the overhead of recreating channels and
  @@queue_connection = nil
  @@channel = nil
  @@fanout_channel = nil

  def get_connection
    if @@queue_connection
      @@queue_connection
    else
      @@queue_connection = MessageQueue.new.get_connection
      @@queue_connection
    end
  end

  def get_channel
    if @@channel
      @@channel
    else
      connection = self.get_connection
      @@channel = connection.create_channel
      @@channel
    end
  end

  def get_fanout_channel
    if @@fanout_channel
      @@fanout_channel
    else
      channel = self.get_channel
      @@fanout_channel = channel.fanout 'champaign'
      @@fanout_channel
    end
  end
end
