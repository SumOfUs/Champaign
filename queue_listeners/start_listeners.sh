#!/usr/bin/env bash

# This file starts up any number of listeners for performing background
# actions within Champaign. These are all idempotent from one another,
# meaning that disabling one or all of them will not have a
# direct impact on the operation of Champaign itself.


# Blocking listeners. These should be run in the background (append & to the command)
# because they're blocking, and thus need to run indefinitely.
echo "Starting blocking listeners"
/usr/local/bin/ruby /queue_listeners/listeners/create_page_listener.rb &
