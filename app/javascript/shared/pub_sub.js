// @flow

import EventEmitter from 'eventemitter3';

let ee = window.ee;
if (!ee) {
  ee = new EventEmitter();
}

export default ee;
