import isPlainObject from 'lodash/isPlainObject';
import forEach from 'lodash/forEach';
import camelCase from 'lodash/camelCase';
import isArray from 'lodash/isArray';

export const camelizeKeys = (obj) => {
  if(isPlainObject(obj)) {
    const ret = {};
    forEach(obj, (value, key) => {
      const newKey = camelCase(key);
      const newValue = camelizeKeys(value);
      ret[newKey] = newValue;
    });
    return ret;
  }
  else if (isArray(obj)) {
    return obj.map(val => { return camelizeKeys(val);});
  }
  else {
    return obj;
  }
};
