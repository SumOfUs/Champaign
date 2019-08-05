import { load, SUPPORTED_PLUGINS } from '../plugins';
import '../plugins/index.css';

const champaign = window.champaign;

document.addEventListener('DOMContentLoaded', function() {
  const plugins = champaign.plugins || {};

  Object.keys(plugins).forEach(name => {
    if (!SUPPORTED_PLUGINS[name]) {
      // tslint:disable-next-line: no-console
      console.log(`plugin: ${name} is not supported`);
      return;
    }

    const data = plugins[name];
    const refs = Object.keys(data);

    refs.forEach(async ref => {
      const p = data[ref];
      if (!p) {
        return;
      }
      p.instance = await load(name, ref, p.config);
    });
  });
});
