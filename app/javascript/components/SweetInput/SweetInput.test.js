// @flow
import React from 'react';
import { shallow, mount } from 'enzyme';
import SweetInput from './SweetInput';

it('renders no problem 💅', () => {
  const wrapper = shallow(<SweetInput name="testInput" label="TEST LABEL" />);
  expect(wrapper.text()).toEqual('TEST LABEL');
});

it('contains a label', () => {
  const wrapper = shallow(<SweetInput name="testInput" label="TEST LABEL" />);
  expect(wrapper.containsMatchingElement(<label>TEST LABEL</label>)).toEqual(
    true
  );
});

it('contains an input', () => {
  const wrapper = shallow(<SweetInput name="testInput" label="TEST LABEL" />);
  expect(wrapper.containsMatchingElement(<input />)).toEqual(true);
});

it('renders an input of type `text` by default', () => {
  const wrapper = shallow(<SweetInput name="testInput" label="TEST LABEL" />);
  expect(wrapper.find('input').prop('type')).toEqual('text');
});

it('accepts custom input types', () => {
  const telWrapper = shallow(
    <SweetInput type="tel" name="testInput" label="TEST LABEL" />
  );
  const emailWrapper = shallow(
    <SweetInput type="email" name="testInput" label="TEST LABEL" />
  );
  expect(telWrapper.find('input').prop('type')).toEqual('tel');
  expect(emailWrapper.find('input').prop('type')).toEqual('email');
});

it('floats the label when the input is focused', () => {
  const wrapper = mount(<SweetInput name="testInput" label="TEST LABEL" />);
  wrapper.find('input').simulate('focus');
  // We can't do wrapper.hasClass() because of this
  // bug: https://github.com/airbnb/enzyme/issues/134
  // We need to get the root dom element for our assertion
  expect(
    wrapper
      .find('.sweet-placeholder__label')
      .hasClass('sweet-placeholder__label--active')
  ).toBeTruthy();
});

it('floats the label when the input has a value', () => {
  const wrapper = mount(
    <SweetInput value="TEST VALUE" name="testInput" label="TEST LABEL" />
  );
  expect(
    wrapper
      .find('.sweet-placeholder__label')
      .hasClass('sweet-placeholder__label--full')
  ).toBeTruthy();
});

it('accepts an `onChange` callback prop', () => {
  const fn = jest.fn();
  const wrapper = mount(
    <SweetInput name="testInput" label="TEST LABEL" onChange={fn} />
  );
  const input = wrapper.find('input');
  input.getDOMNode().value = 'test value';
  input.simulate('change');
  expect(fn).toHaveBeenCalledWith('test value');
});
