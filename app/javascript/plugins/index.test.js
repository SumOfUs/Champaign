// @flow
import { SUPPORTED_PLUGINS, Plugin, load } from './index';
import * as EventEmitter from 'eventemitter3';
import { each } from 'lodash';

describe('Plugin (interface)', function() {
  test('creates an EventEmitter', () => {
    const plugin = new Plugin({ namespace: 'petition' });
    expect(plugin.events).toBeInstanceOf(EventEmitter);
  });

  test(`prepends event names with the plugin's namespace`, () => {
    const plugin = new Plugin({ namespace: 'petition' });
    jest.spyOn(plugin.events, 'emit');

    plugin.update({ namespace: 'petition' });
    expect(plugin.events.emit).toHaveBeenCalledWith(
      'petition:updated',
      undefined
    );

    plugin.update({ namespace: 'petition2' });
    expect(plugin.events.emit).toHaveBeenCalledWith(
      'petition2:updated',
      undefined
    );
  });

  test(`keeps a reference to the dom element it's referencing`, () => {
    const plugin = new Plugin({ el: document.createElement('div') });
    expect(plugin.el).toBeTruthy();
  });
});

describe('loader', function() {
  test('returns undefined if no plugin matching `name`', async () => {
    expect(await load('test', 'test')).toEqual(undefined);
  });
});
