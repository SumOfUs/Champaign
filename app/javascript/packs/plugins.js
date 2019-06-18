// @flow
import { SUPPORTED_PLUGINS, load } from '../plugins';

const dict = window.champaign.plugins;

document.addEventListener('DOMContentLoaded', function() {
  const plugins = window.champaign.plugins || {};

  for (let name in SUPPORTED_PLUGINS) {
    if (!plugins[name]) {
      console.log(`plugin: ${name} is not supported`);
      return;
    }

    const data = plugins[name];
    const refs = Object.keys(data);

    refs.forEach(async ref => {
      const p = data[ref];
      if (!p) return;
      p.instance = await load(name, ref, p.config);
    });
  }
});
