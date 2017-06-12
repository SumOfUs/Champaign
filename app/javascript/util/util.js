import _ from "lodash";

export const camelizeKeys = obj => {
  if (_.isPlainObject(obj)) {
    const ret = {};
    _.forEach(obj, (value, key) => {
      const newKey = _.camelCase(key);
      const newValue = camelizeKeys(value);
      ret[newKey] = newValue;
    });
    return ret;
  } else if (_.isArray(obj)) {
    return obj.map(val => {
      return camelizeKeys(val);
    });
  } else {
    return obj;
  }
};
