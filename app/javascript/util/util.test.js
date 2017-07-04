// @flow
import { camelizeKeys } from './util';
import { mapValues, mapKeys } from 'lodash';

const fixture: Object = {
  camelCaseKey: 'lorem',
  snake_case_key: 'ipsum',
  'kebab-case-key': 'dolor',
  PascalCaseKey: 'sit',
  'Strangely-formatted_KeyName': 'Strangely-formatted_KeyValue',
  array_with_objects: [
    { snake_case: 'snake_case' },
    { 'kebab-case': 'kebab-case' },
  ],
  camel_case_subgroup: {
    number_key: 1,
    letter_key: 'a',
    array_key: [0, 1, 2],
    object_key: {
      'kebab-case-key': 'value',
    },
  },
};

it('keeps camelCase keys intact', () => {
  expect(camelizeKeys(fixture)).toHaveProperty('camelCaseKey');
  expect(camelizeKeys(fixture)).toHaveProperty('arrayWithObjects');
});

it('converts snake_case keys to camelCase', () => {
  expect(camelizeKeys(fixture)).toHaveProperty('snakeCaseKey', 'ipsum');
});

it('converts kebab-case keys to camelCase', () => {
  expect(camelizeKeys(fixture)).toHaveProperty('kebabCaseKey', 'dolor');
});

it('converts PascalCase keys to camelCase', () => {
  expect(camelizeKeys(fixture)).toHaveProperty('pascalCaseKey', 'sit');
});

it('converts Stragely-formatted_KeyNames to camelCase', () => {
  expect(camelizeKeys(fixture)).toHaveProperty(
    'strangelyFormattedKeyName',
    'Strangely-formatted_KeyValue'
  );
});

it('converts array items', () => {
  const camelizedArray = camelizeKeys(fixture).arrayWithObjects;
  expect(camelizedArray[0]).toHaveProperty('snakeCase', 'snake_case');
  expect(camelizedArray[1]).toHaveProperty('kebabCase', 'kebab-case');
});

it('converts nested keys', () => {
  expect(camelizeKeys(fixture).camelCaseSubgroup).toHaveProperty('numberKey');
});

it('converts deeply nested keys', () => {
  const { camelCaseSubgroup } = camelizeKeys(fixture);
  expect(camelCaseSubgroup.objectKey).toHaveProperty('kebabCaseKey');
});

describe('values', () => {
  it('keeps strings intact', () => {
    expect(camelizeKeys(fixture).camelCaseKey).toBe('lorem');
  });

  it('keeps numbers intact', () => {
    const { camelCaseSubgroup } = camelizeKeys(fixture);
    expect(camelCaseSubgroup.numberKey).toBe(1);
  });

  it('keeps arrays intact', () => {
    expect(Array.isArray(camelizeKeys(fixture).arrayWithObjects)).toBeTruthy();
  });
});
