import { SUPPORTED_PLUGINS, load } from '../plugins';
import { ChampaignGlobalObject } from 'interfaces';

const champaign: ChampaignGlobalObject = (<any>window)['champaign'];

document.addEventListener('DOMContentLoaded', function() {
  const plugins = champaign.plugins || {};

  Object.keys(plugins).forEach(name => {
    if (!SUPPORTED_PLUGINS[name]) {
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
  });
});
