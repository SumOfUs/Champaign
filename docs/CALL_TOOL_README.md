# Call Tool

## Call Tool Plugin

The Call Tool is implemented as a Page plugin (`Plugins::CallTool`). Every plugin instance has the
following fields:

* `targets`: json array that holds the targets information (the json contents are
automatically mapped to `CallTool::Target` instances)
* `sound_clip`: paperclip attachment that holds a recorded audio file that should include a
message and instructions from the campaigner about the campaign.
* `menu_sound_clip`: paperclip attachment that holds a recorded audio file to be used as a
menu during a call (Press 1 to connect, press 2 to hear the campaigner's message again)


## Call flow

To make phone calls we use an external service provided by Twilio. In order to know how to handle
a particular call, Twilio makes request to our server and expects to return a Twiml file (xml).
The returned Twiml file will hold the instructions that tell Twilio how to proceed with the call.

This is a simplified overview of the flow of a call:

* A member visits a page that has the call tool plugin. He's presented with a form that will make a
`POST /api/call` request to the backend sending these two params: `target_id` and
`member_phone_number`.

* The backend creates an instance of `Call` and makes a request to Twilio to initiate a call
sending the member's phone number and the Twiml callback URL with instructions on how to handle
the call.

* Twilio makes a call to the member and then immediately makes a request to
`twilio/calls/:id/start`. The `start` instructions (see `CallTool::TwimlGenerator::Start`) tell
Twilio to play the sound clip with the campaigner's message and then is redirected to
`twilio/calls/:id/menu`.

* When Twilio makes a request to `twilio/calls/:id:/menu` the menu is played, and the key presses
are captured. If the member presses 1 it's redirected to `twilio/calls/:id/start`, and if the member
presses 2 it's redirected to the next step at `twilio/calls/:id/connect`. See
`CallTool::TwimlGenerator::Menu`.

* `twilio/calls/:id/connect` tells twilio to make a call to the target's phone number and bridge it
with the in-progress call to the member.


## Call state

The status of a call is quite complex, since in the simplified flow I just described at any step
something can go wrong in a couple of different ways.

The full state of a call is stored in three different places, and it's the combination of three
different state machines.

1. **AR Call status:** This the main status of the call, it's stored in `Call#status` as an
enum. The possible statuses are:
  * `:failed`: A request was made to Twilio to initiate a call and it responded with an error
  message. This usually means the number is invalid.
  * `:unstarted`: This means that the call was made to the member but either the line was busy,
  never picked up or the phone was disconnected.
  * `:started`: This means the member picked up the phone and started hearing the campaignerer's
  message
  * `:connected`: This means the member pressed 1 and got connected to the target.

2. **Member call status:** This holds the details of the actual phone call made to the member by
Twilio. Twilio sends Champaign events when the status of a call changes, and they are stored in:
`Call#member_call_events`. So in order to know the last state of a call we need to do
`call.member_call_events.last['CallStatus']`. The possible statuses are: `completed`,
`answered`, `busy`, `no-answer`, `failed`, `canceled` and `unknown`. To understand what each status
means please check out
[Twilio's docs](https://www.twilio.com/docs/api/twiml/twilio_request#request-parameters-call-status).
I added an extra status `unknown` to describe the case when we don't receive a callback from Twilio.

3. **Target call status:** This holds the details of the actual phone call made to the target by
Twilio. This is sent in a callback request and stored in `Call#target_call_info['DialCallStatus']`.
To know the possible states and their meanings please see
[Twilio's docs](https://support.twilio.com/hc/en-us/articles/223132547-What-do-the-call-statuses-mean-)
