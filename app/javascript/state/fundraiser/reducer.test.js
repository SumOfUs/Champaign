// @flow
import { isFunction } from 'lodash';
import { initialState } from './helpers';
import reducer from './reducer';

test('is a function', () => {
  expect(isFunction(reducer)).toEqual(true);
});

describe('[action] search_string_overrides', () => {
  test('does not change the structure of state', () => {
    const state = reducer(initialState, {
      type: 'search_string_overrides',
      payload: {},
    });
    expect(Object.keys(state)).toEqual(Object.keys(initialState));
  });

  test('hides saved payment methods if hide_spm is "1"', () => {
    const state = reducer(initialState, {
      type: 'search_string_overrides',
      payload: { hide_spm: '1' },
    });

    expect(initialState).toHaveProperty('disableSavedPayments', false);
    expect(state).toHaveProperty('disableSavedPayments', true);
  });
});
