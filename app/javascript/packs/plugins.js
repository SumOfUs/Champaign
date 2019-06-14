// @flow
import { SUPPORTED_PLUGINS, load } from '../plugins';

const dict = window.champaign.plugins;

document.addEventListener('DOMContentLoaded', function() {
  const plugins = window.champaign.plugins || {};

  for (let name in SUPPORTED_PLUGINS) {
    if (!plugins[name]) return;
    const data = plugins[name];
    const refs = Object.keys(data);

    refs.forEach(async ref => {
      if (!data[ref]) return;
      const config = data[ref];
      await load(name, ref, config);
    });
  }
});
