import Plugin from './plugin';
import * as EventEmitter from 'eventemitter3';

describe('Plugin (interface)', function() {
  const el = document.createElement('div');
  const config = { active: true };
  test('creates an EventEmitter', () => {
    const plugin = new Plugin({ el, config, namespace: 'petition' });
    const listener = jest.fn();
    plugin.events.on('test-event', listener);
    plugin.events.emit('test-event', true);
    expect(listener).toHaveBeenCalledWith(true);
  });

  test(`prepends event names with the plugin's namespace`, () => {
    const plugin = new Plugin({ el, config, namespace: 'petition' });
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
    const plugin = new Plugin({ el, config, namespace: 'petition' });
    expect(plugin.el).toBeTruthy();
  });
});
