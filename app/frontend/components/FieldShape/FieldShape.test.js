import React from 'react';
import { shallow } from 'enzyme';
import FieldShape from './FieldShape';

const field = {
  data_type: 'text',
  name: 'testField',
  label: 'Test Field',
  default_value: 'test value',
};

it('renders successfully', () => {
  const wrapper = shallow(<FieldShape field={field} />);
  expect(wrapper.instance()).toBeInstanceOf(FieldShape);
});
it(`renders a <SweetInput type="text" .../> if (data_type === 'text')`, () => {
  const wrapper = shallow(<FieldShape field={field} />);
  expect(wrapper.text()).toEqual('<SweetInput />');
  expect(wrapper.prop('type')).toEqual('text');
});

it(`renders a <SweetInput type="text" .../> if (data_type === 'postal')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'postal'}} />);
  expect(wrapper.text()).toEqual('<SweetInput />');
  expect(wrapper.prop('type')).toEqual('text');
});

it(`renders a <SweetInput type="email" .../> if (data_type === 'email')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'email'}} />);
  expect(wrapper.text()).toEqual('<SweetInput />');
  expect(wrapper.prop('type')).toEqual('email');
});

it(`renders a <SweetInput type="email" .../> if (data_type === 'email')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'email'}} />);
  expect(wrapper.text()).toEqual('<SweetInput />');
  expect(wrapper.prop('type')).toEqual('email');
});

it(`renders a <SweetInput type="tel" .../> if (data_type === 'phone')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'phone'}} />);
  expect(wrapper.text()).toEqual('<SweetInput />');
  expect(wrapper.prop('type')).toEqual('tel');
});

it(`renders a <SweetInput type="tel" .../> if (data_type === 'numeric')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'numeric'}} />);
  expect(wrapper.text()).toEqual('<SweetInput />');
  expect(wrapper.prop('type')).toEqual('tel');
});

it(`renders a <SelectCountry .../> if (data_type === 'country')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'country'}} />);
  expect(wrapper.text()).toEqual('<SelectCountry />');
});

it(`renders a <SelectCountry .../> if (data_type === 'dropdown')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'dropdown'}} />);
  expect(wrapper.text()).toEqual('<Select />');
});

it(`renders a <SelectCountry .../> if (data_type === 'dropdown')`, () => {
  const wrapper = shallow(<FieldShape field={{...field, data_type: 'hidden'}} />);
  expect(wrapper.type()).toEqual('input');
  expect(wrapper.prop('type')).toBe('hidden');
});
