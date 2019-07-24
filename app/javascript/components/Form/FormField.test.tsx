import Enzyme, { render, shallow } from 'enzyme';
import * as React from 'react';
import SelectCountry from '../SelectCountry/SelectCountry';
import FormField from './FormField';

describe('Form Field', function() {
  const config = {
    id: '1',
    display_mode: 'all_members',
    form_id: 1,
    choices: [],
    default_value: undefined,
    label: 'Field One',
    name: 'field1',
    required: true,
    position: 0,
    visible: true,
  };

  test(`data_type: file => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'file' };
    const wrapper = shallow(<FormField {...cnf} />);
    expect(wrapper.text().trim()).toContain('not implemented');
  });

  test(`data_type: text => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'text' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Input />');
    expect(input.prop('data_type')).toEqual('text');
  });

  test(`data_type: email => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'email' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Email />');
  });

  test(`data_type: numeric => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'numeric' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Tel />');
  });

  test(`data_type: phone => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'phone' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Tel />');
  });

  test(`data_type: postal => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'postal' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Input />');
  });

  test(`data_type: hidden => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'hidden' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Hidden />');
  });

  test(`data_type: instruction => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'instruction' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Instruction />');
  });

  test(`data_type: paragraph => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'paragraph' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Paragraph />');
  });

  test(`data_type: checkbox => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'checkbox' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Checkbox />');
  });

  test(`data_type: choice => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'choice' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Choice />');
  });

  test(`data_type: country => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'country' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Country />');
  });

  test(`data_type: dropdown => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'dropdown' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Select />');
  });

  test(`data_type: select => <FormField .../>`, () => {
    const cnf = { ...config, data_type: 'select' };
    const wrapper = shallow(<FormField {...cnf} />);
    const input = wrapper.children();

    expect(wrapper.text()).toEqual('<FormGroup />');
    expect(input.text()).toEqual('<Select />');
  });
});

describe('Form Field Error Messages', function() {
  const config = {
    id: '1',
    display_mode: 'all_members',
    form_id: 1,
    choices: [],
    default_value: undefined,
    label: 'Field One',
    name: 'field1',
    required: true,
    position: 0,
    visible: true,
    errorMessage: 'Invalid data',
    hasError: true,
  };

  let fieldTypes = [
    'text',
    'email',
    'phone',
    'numeric',
    'postal',
    'paragraph',
    'choice',
    'dropdown',
  ];

  fieldTypes.forEach(type => {
    test(`data_type: ${type} => <FormField .../>`, () => {
      const cnf = { ...config, data_type: type };
      const wrapper = render(<FormField {...cnf} />);
      expect(wrapper.find('span').text()).toMatch('Invalid data');
    });
  });

  // Fields which does not have any error messages
  fieldTypes = ['hidden', 'checkbox'];

  fieldTypes.forEach(type => {
    test(`data_type: ${type} => <FormField .../>`, () => {
      const cnf = { ...config, data_type: type };
      const wrapper = render(<FormField {...cnf} />);
      expect(wrapper.find('span').text()).toMatch('');
    });
  });
});
