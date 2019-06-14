// @flow
import { SUPPORTED_PLUGINS, Plugin, load } from './index';
import { each } from 'lodash';

describe('Plugin (interface)', function() {
  test('is an EventEmitter', () => {
    const plugin = new Plugin();
    plugin.on('test-event', jest.fn());
    expect(plugin.eventNames()).toEqual(expect.arrayContaining(['test-event']));
    expect(plugin.listeners('test-event')).toHaveLength(1);
  });

  test(`prepends event names with the plugin's namespace`, () => {
    const plugin = new Plugin({ namespace: 'petition' });
    jest.spyOn(plugin, 'emit');

    plugin.update({ namespace: 'petition' });
    expect(plugin.emit).toHaveBeenCalledWith('petition:update');

    plugin.update({ namespace: 'petition2' });
    expect(plugin.emit).toHaveBeenCalledWith('petition2:update');
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
