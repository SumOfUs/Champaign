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
    expect(wrapper.find('SweetInput').prop('type')).toEqual('text');
  });

  test(`postal => <SweetInput type="text" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'postal'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.find('SweetInput').prop('type')).toEqual('text');
  });

  test(`email => <SweetInput type="email" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'email'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.find('SweetInput').prop('type')).toEqual('email');
  });

  test(`phone => <SweetInput type="tel" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'phone'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.find('SweetInput').prop('type')).toEqual('tel');
  });

  test(`numeric => <SweetInput type="tel" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'numeric'}} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.find('SweetInput').prop('type')).toEqual('tel');
  });

  test(`country => <SelectCountry .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'country'}} />);
    expect(wrapper.text()).toEqual('<SelectCountry />');
  });

  test(`dropdown => <Select .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'dropdown'}} />);
    expect(wrapper.text()).toEqual('<SweetSelect />');
  });

  test(`hidden => <input type="hidden" .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'hidden'}} />);
    expect(wrapper.find('input').prop('type')).toEqual('hidden');
  });

  test(`choice => Radio buttons`, () => {
    const choices = [{id: 'a1', value: 'a2', 'label': 'a3'}, {id: 'b1', value: 'b2', 'label': 'b3'}];
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'choice', choices: choices }} />);
    expect(wrapper.find('label').length).toEqual(2);
    expect(wrapper.find('input').length).toEqual(2);

    expect(wrapper.find('input').first().prop('id')).toEqual('a1');
    expect(wrapper.find('input').first().prop('value')).toEqual('a2');
  });

  test(`paragraph => <textarea>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'paragraph'}} />);
    expect(wrapper.find('textarea').length).toEqual(1);
  });

  test(`checkbox => <Checkbox .../>`, () => {
    const wrapper = shallow(<FieldShape field={{...field, data_type: 'checkbox'}} />);
    expect(wrapper.find('Checkbox').length).toEqual(1);
  });
});
