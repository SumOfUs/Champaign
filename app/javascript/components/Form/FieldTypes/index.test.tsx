import Enzyme, { shallow } from 'enzyme';
import * as React from 'react';
import {
  Checkbox,
  Choice,
  Country,
  Hidden,
  Input,
  Instruction,
  Paragraph,
  Select,
} from './index';

const defaultConfig = {
  choices: [],
  data_type: 'input',
  default_value: undefined,
  display_mode: 'all_members',
  form_id: 1,
  id: '1',
  label: 'Label',
  name: 'fieldName',
  position: 0,
  required: true,
  visible: true,
};

describe('Input Field', function() {
  const config = {
    ...defaultConfig,
    className: 'field1',
    errorMessage: 'Invalid Value',
    name: 'field1',
    required: true,
  };

  test(`default type => <Input .../>`, () => {
    const wrapper = shallow(<Input {...config} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.find('SweetInput').prop('type')).toEqual('text');
  });

  ['text', 'email', 'tel', 'numeric'].forEach(type => {
    test(`text => <Input type="${type}" .../>`, () => {
      const cnf = { ...config, type };
      const wrapper = shallow(<Input {...cnf} />);

      expect(wrapper.text()).toEqual('<SweetInput />');
      expect(wrapper.find('SweetInput').prop('type')).toEqual(type);
    });
  });
});

describe('Choice Field', function() {
  const choices = [
    { id: 'a1', value: 'a2', label: 'a3' },
    { id: 'b1', value: 'b2', label: 'b3' },
  ];
  const config = {
    ...defaultConfig,
    choices,
    name: 'field2',
    className: 'field2',
    default_value: 'b2',
  };
  test(`choice => Radio buttons`, () => {
    const wrapper = shallow(<Choice {...config} />);
    expect(wrapper.find('label').length).toEqual(2);
    expect(wrapper.find('input').length).toEqual(2);

    expect(
      wrapper
        .find('input')
        .first()
        .prop('id')
    ).toEqual('a1');
    expect(
      wrapper
        .find('input')
        .first()
        .prop('value')
    ).toEqual('a2');
    expect(
      wrapper
        .find('input')
        .last()
        .prop('checked')
    ).toEqual(true);
    expect(
      wrapper
        .find('input')
        .first()
        .prop('checked')
    ).toEqual(false);
  });
});

describe('Checkbox Field', function() {
  const config = {
    ...defaultConfig,
    name: 'field1',
    label: 'Sample Field',
    className: 'field1',
  };

  test(`checkbox => <Checkbox .../>`, () => {
    const wrapper = shallow(<Checkbox {...config} />);

    expect(wrapper.find('Checkbox').length).toEqual(1);
    expect(wrapper.find('Checkbox').prop('label')).toEqual('Sample Field');
  });
});

describe('Paragraph', function() {
  const config = {
    ...defaultConfig,
    name: 'field1',
    label: 'field1',
    required: true,
    className: 'field1',
    errorMessage: 'Invalid Value',
  };
  test(`paragraph => <textarea>`, () => {
    const wrapper = shallow(<Paragraph {...config} />);
    expect(wrapper.find('textarea').length).toEqual(1);
    expect(wrapper.find('textarea').prop('maxLength')).toEqual(9999);
    expect(wrapper.find('textarea').prop('placeholder')).toEqual(config.label);
  });
});

describe('Hidden Field', function() {
  const config = { ...defaultConfig, name: 'field4', data_type: 'hidden' };
  test(`hidden => <input type="hidden" .../>`, () => {
    const wrapper = shallow(<Hidden {...config} />);
    expect(wrapper.find('input').prop('type')).toEqual('hidden');
  });
});

describe('Dropdown Field', function() {
  const choices = [
    { id: '1', label: 'One', value: '1' },
    { id: '2', label: 'Two', value: '2' },
  ];
  const config = {
    ...defaultConfig,
    name: 'field2',
    label: 'field1',
    choices,
    className: 'field2',
    default_value: '1',
  };

  test(`dropdown => <Select .../>`, () => {
    const wrapper = shallow(<Select {...config} />);
    expect(wrapper.text()).toEqual('<SweetSelect />');
    expect(wrapper.prop('value')).toEqual({ label: 'One', value: '1' });
  });
});

describe('Country Field', function() {
  const config = { ...defaultConfig, name: 'field5' };

  test(`country => <SelectCountry .../>`, () => {
    const wrapper = shallow(<Country {...config} />);
    expect(wrapper.text()).toEqual('<InjectIntl(SelectCountry) />');
  });
});

describe('Instruction Field', function() {
  const config = {
    ...defaultConfig,
    name: 'field6',
    label: 'Instruction message goes here..',
  };

  test(`instruction => <div .../>`, () => {
    const wrapper = shallow(<Instruction {...config} />);
    expect(wrapper.text()).toEqual('Instruction message goes here..');
  });
});
