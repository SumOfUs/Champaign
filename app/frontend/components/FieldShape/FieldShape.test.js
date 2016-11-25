import React from 'react';
import { shallow, mount } from 'enzyme';
import FieldShape from './FieldShape';

const field = {
  data_type: 'text',
  name: 'testField',
  label: 'Test Field',
  default_value: 'test value',
};

test('renders successfully', () => {
  const wrapper = mount(<FieldShape field={field} />);
  expect(wrapper.instance()).toBeInstanceOf(FieldShape);
});

describe('Match "data_type"', function () {
  test(`text => <SweetInput type="text" .../>`, () => {
    const wrapper = shallow(<FieldShape field={field} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.prop('type')).toEqual('text');
  });

  test(`postal => <SweetInput type="text" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'postal'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.prop('type')).toEqual('text');
  });

  test(`email => <SweetInput type="email" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'email'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.prop('type')).toEqual('email');
  });

  test(`phone => <SweetInput type="tel" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'phone'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.prop('type')).toEqual('tel');
  });

  test(`numeric => <SweetInput type="tel" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'numeric'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.prop('type')).toEqual('tel');
  });

  test(`country => <SelectCountry .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'country'}} />);
    expect(wrapper.text()).toEqual('<SelectCountry />');
  });

  test(`dropdown => <Select .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'dropdown'}} />);
    expect(wrapper.text()).toEqual('<Select />');
  });

  test(`hidden => <input type="hidden" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'hidden'}} />);
    expect(wrapper.type()).toEqual('input');
    expect(wrapper.prop('type')).toEqual('hidden');
  });

  test(`text => <SweetInput type="text" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'text'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.prop('type')).toEqual('text');
  });

  test(`choice => ??? [PENDING]`);
  test(`checkbox=> ??? [PENDING]`);
});
