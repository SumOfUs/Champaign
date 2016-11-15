// @flow
import React from 'react';
import { shallow } from 'enzyme';
import Button from './Button';

it(`accepts an onClick event handler`, () => {
  const fn = jest.fn();
  const wrapper = shallow(<Button onClick={fn} />);
  expect(fn.mock.calls.length).toBe(0);
  wrapper.simulate('click');
  expect(fn.mock.calls.length).toBe(1);
});

it(`accepts a className`, () => {
  const wrapper = shallow(<Button className="test"/>);
  expect(wrapper.hasClass('test')).toBeTruthy();
});

it(`can render nested children`, () => {
  const wrapper = shallow(
    <Button>
      <p>Child</p>
    </Button>
  );
  expect(wrapper.childAt(0).text()).toMatch(/Child/);
});
