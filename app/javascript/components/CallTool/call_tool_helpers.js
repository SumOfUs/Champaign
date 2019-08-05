import { compact, get, isMatchWith, pick, uniq, without } from 'lodash';

export function targetsWithFields(targets) {
  return targets.map(t => ({
    ...pick(t, without(Object.keys(t), 'fields')),
    ...get(t, 'fields', {}),
  }));
}

const caseInsensitiveComp = (objValue, srcValue) => {
  if (typeof objValue === 'string' && typeof srcValue === 'string') {
    return objValue.toLowerCase() === srcValue.toLowerCase();
  } else {
    return objValue === srcValue;
  }
};

export function filterTargets(targets, filters) {
  if (!Object.keys(filters).length) return targets;
  return targets.filter(t => isMatchWith(t, filters, caseInsensitiveComp));
}

export function valuesForFilter(targets, attrs, filters, filter) {
  const activeFilters = pick(filters, attrs.slice(0, attrs.indexOf(filter)));
  return compact(
    uniq(filterTargets(targets, activeFilters).map(t => t[filter]))
  );
}
