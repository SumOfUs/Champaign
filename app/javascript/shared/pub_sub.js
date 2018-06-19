// @flow

import EventEmitter from 'eventemitter3';

let event = window.event;
if (!event) {
  event = new EventEmitter();
}

export default event;
