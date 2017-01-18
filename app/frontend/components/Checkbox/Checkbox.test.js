// @flow
import React from 'react';
import {  shallow } from 'enzyme';
import Checkbox from './Checkbox';

it('renders checkbox field', () => {
  const wrapper = shallow(<Checkbox />);

  expect(wrapper.find('input').
         prop('type')).
         toEqual('checkbox');
});

it('renders children', () => {
  const wrapper = shallow(
    <Checkbox><p>Hello</p></Checkbox>
  );

  expect(wrapper.find('p').length).toBe(1);
});

it('can be disabled', () => {
  const wrapper = shallow(<Checkbox disabled={true}/>);

  expect(wrapper.find('input').
         prop('disabled')).
         toBeTrue;
});

it('can be checked', () => {
  const wrapper = shallow(<Checkbox checked={true}/>);

  expect(wrapper.find('input').
         prop('checked')).
         toBeTrue;
});

it('invokes hanlder on change event', () => {
  const onChange = jest.fn();
  const wrapper = shallow(<Checkbox onChange={onChange}/>);
  wrapper.find('input').simulate('change');
  expect(onChange.mock.calls.length).toBe(1);
});
