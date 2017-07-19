// @flow
import { compact, get, isMatch, pick, uniq, without } from 'lodash';
import type { Target } from '../../call_tool/CallToolView';

export type TargetWithFields = { [string]: any };
export type Filters = { [string]: string };

export function targetsWithFields(targets: Target[]): TargetWithFields[] {
  return targets.map((t: Target): TargetWithFields => ({
    ...pick(t, without(Object.keys(t), 'fields')),
    ...get(t, 'fields', {}),
  }));
}

export function filterTargets(
  targets: TargetWithFields[],
  filters: Filters
): TargetWithFields[] {
  if (!Object.keys(filters).length) return targets;
  return targets.filter(t => isMatch(t, filters));
}

export function valuesForFilter(
  targets: TargetWithFields[],
  attrs: string[],
  filters: { [string]: string },
  filter: string
): string[] {
  const activeFilters = pick(filters, attrs.slice(0, attrs.indexOf(filter)));
  return compact(
    uniq(filterTargets(targets, activeFilters).map(t => t[filter]))
  );
}
