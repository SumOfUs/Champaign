// @flow
import { flattenObject, transform, translateInterpolations } from './helpers';

describe('flattenObject', () => {
  it('keeps top level key/value pairs of strings', () => {
    const data = {
      key: 'value',
    };
    expect(flattenObject(data)['key']).toEqual('value');
  });

  it('flattens nested keys', () => {
    const data = { key: { key: 'value' } };
    expect(flattenObject(data)['key.key']).toEqual('value');
  });

  it('flattens deeply nested keys', () => {
    const data = { key: { key: { key: { key: 'value' } } } };
    expect(flattenObject(data)['key.key.key.key']).toEqual('value');
  });

  it('flattens a mixture of nested levels', () => {
    const data = {
      one: 'value',
      two: {
        one: 'value',
      },
      three: {
        two: {
          one: 'value',
        },
      },
      four: {
        three: {
          two: {
            one: 'value',
          },
        },
      },
    };

    const flattenedData = flattenObject(data);
    expect(flattenedData['one']).toEqual('value');
    expect(flattenedData['two.one']).toEqual('value');
    expect(flattenedData['three.two.one']).toEqual('value');
    expect(flattenedData['four.three.two.one']).toEqual('value');
  });

  // TODO
  // At the moment it's okay to skip, but it would be "nice" to throw
  // an error when we detect a null, function or integer value, so that the
  // developer passing the object to it will have meaningful feedback that we're
  // passing an invalid type of "Dictionary"
  // Here, we're testing that nulls/undefineds, functions, and numbers are
  // not present in the resulting object.

  it('skips null/undefined values', () => {
    const data = {
      empty: null,
      undef: undefined,
      key: 'value',
    };
    expect(flattenObject(data)).not.toHaveProperty('empty');
    expect(flattenObject(data)).not.toHaveProperty('undef');
    expect(flattenObject(data)).toHaveProperty('key', 'value');
  });

  it('skips function values', () => {
    const data = {
      fn: () => null,
      key: 'value',
    };
    expect(flattenObject(data)).not.toHaveProperty('fn');
    expect(flattenObject(data)).toHaveProperty('key', 'value');
  });

  it('skips function values', () => {
    const data = {
      fn: () => null,
      key: 'value',
    };
    expect(flattenObject(data)).not.toHaveProperty('fn');
    expect(flattenObject(data)).toHaveProperty('key', 'value');
  });
});

describe('translateInterpolations', () => {
  it('replaces all %{variable} ocurrences for {variable}', () => {
    const data = { greeting: 'Hello %{name}, you are %{age} year(s) old.' };
    const expected = { greeting: 'Hello {name}, you are {age} year(s) old.' };
    expect(translateInterpolations(data)).toMatchObject(expected);
  });
});

describe('transform', () => {
  it('flattens an object then translates interpolations', () => {
    const data = { greetings: { welcome: 'Welcome, %{username}' } };
    const expected = { 'greetings.welcome': 'Welcome, {username}' };
    expect(transform(data)).toMatchObject(expected);
  });
});
