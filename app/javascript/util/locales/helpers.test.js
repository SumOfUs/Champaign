// @flow
import { transform, replaceInterpolations } from './helpers';

describe('replaceInterpolations', () => {
  it('replaces all %{variable} ocurrences for {variable}', () => {
    const data = 'Hello %{name}, you are %{age} year(s) old.';
    const expected = 'Hello {name}, you are {age} year(s) old.';
    expect(replaceInterpolations(data)).toEqual(expected);
  });
});

describe('transform', () => {
  it('flattens an object and replaces interpolations', () => {
    const data = {
      greetings: {
        welcome: 'Welcome, %{username}',
        goodbye: 'Goodbye, %{username}',
      },
    };
    const expected = {
      'greetings.welcome': 'Welcome, {username}',
      'greetings.goodbye': 'Goodbye, {username}',
    };
    expect(transform(data)).toMatchObject(expected);
  });
});
