// @flow
import { compact, isMatch, pick, uniq } from 'lodash';
import type { Target } from '../../call_tool/CallToolView';

export function valuesForFilter(
  targets: Target[],
  attrs: string[],
  filters: { [string]: string },
  currentFilter: string
): string[] {
  const index = attrs.indexOf(currentFilter);
  const activeFilters = pick(filters, attrs.slice(0, index));
  const values = targets
    .filter(t => isMatch(t, activeFilters))
    .map(t => t[currentFilter]);

  console.debug({
    index,
    attrs,
    activeFilters,
    filters,
    currentFilter,
    targets,
    filteredValues: values,
  });

  return compact(uniq(values));
}
