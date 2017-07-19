// @flow
import faker from 'faker';
import { sample } from 'lodash';
import {
  targetsWithFields,
  filterTargets,
  valuesForFilter,
} from './call_tool_helpers';

const targets = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(id => {
  const country = sample(['United States', 'Canada']);
  let state;
  if (country === 'United States') {
    state = sample(['California', 'New York']);
  } else {
    state = sample(['British Columbia', 'Ontario']);
  }
  return {
    id: id.toString(),
    name: faker.name.findName(),
    title: faker.name.jobTitle(),
    phoneNumber: faker.phone.phoneNumber(),
    country,
    fields: {
      nickname: `nickname${id}`,
      state,
    },
  };
});

describe('targetsWithFields', function() {
  it('expands a target with its `fields` props as top level props', () => {
    const t = targetsWithFields(targets)[0];
    expect(t).not.toHaveProperty('fields.nickname');
    expect(t).toHaveProperty('nickname', 'nickname1');
  });
});

describe('filterTargets', function() {
  it('returns all targets whose props match the filters', () => {
    expect(
      filterTargets(targetsWithFields(targets), {
        nickname: 'nickname2',
      }).length
    ).toBe(1);

    expect(
      filterTargets(targetsWithFields(targets), {
        nickname: 'nickname2',
        id: '1',
      }).length
    ).toBe(0);
  });
});

describe('valuesForFilter', function() {
  const attrs = ['country', 'state'];
  const filters = {
    country: 'United States',
    state: 'California',
  };

  const _targets = targetsWithFields(targets);

  it('returns all values for that property if it is the first filter', () => {
    const filter = 'country';
    const values = valuesForFilter(_targets, attrs, filters, filter);
    expect(values.length).toBe(2);
    expect(values).toContain('United States');
    expect(values).toContain('Canada');
  });

  it('returns values for targets that match all previous filters', () => {
    const filter = 'state';
    const values = valuesForFilter(_targets, attrs, filters, filter);
    // should only return california, and new york
    expect(values).toContain('California');
    expect(values).toContain('New York');
    expect(values).not.toContain('British Columbia');
    expect(values).not.toContain('Ontario');
  });
});
