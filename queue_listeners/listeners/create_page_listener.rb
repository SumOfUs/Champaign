require_relative '../lib/queue_channel_factory'

# Indicates what code should be run on the event that a create page event has been
# published. The goal here is to look at the associated widgets within that page
# and to create pages in ActionKit which are associated to any widgets which should
# have pages attached to them.

factory = QueueChannelFactory.new
connection = factory.get_connection
channel = factory.get_channel
fanout = factory.get_fanout_channel


begin
  file.write('listener_output', '[*] Waiting for messages. To exit press CTRL+C')
  channel.queue('create_page', auto_delete: true).bind(fanout).subscribe(block: true) do |delivery_info, metadata, payload|
    file.write('listener_output', "#{payload} received and processed")
  end
rescue Interrupt => _
  connection.close

  exit(0)
end
