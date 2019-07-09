import * as EventEmitter from 'eventemitter3';
import Plugin from './plugin';

const config = { id: 1, page_id: 1, active: true, ref: 'default' };

describe('Plugin (interface)', function() {
  const el = document.createElement('div');
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
      'petition:default:updated',
      undefined
    );

    plugin.update({ namespace: 'petition2' });
    expect(plugin.events.emit).toHaveBeenCalledWith(
      'petition2:default:updated',
      undefined
    );
  });

  test(`keeps a reference to the dom element it's referencing`, () => {
    const plugin = new Plugin({ el, config, namespace: 'petition' });
    expect(plugin.el).toBeTruthy();
  });
});
