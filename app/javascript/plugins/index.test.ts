import { load } from './index';

describe('loader', function() {
  test('returns undefined if no plugin matching `name`', async () => {
    expect(await load('test', 'test')).toEqual(undefined);
  });
});
