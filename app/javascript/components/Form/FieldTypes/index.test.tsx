import * as React from 'react';
import Enzyme, { shallow } from 'enzyme';
import {
  Input,
  Choice,
  Checkbox,
  Paragraph,
  Hidden,
  Select,
  Country,
  Instruction,
} from './index';

const defaultConfig = {
  id: '1',
  data_type: 'input',
  display_mode: 'all_members',
  form_id: 1,
  choices: [],
  default_value: undefined,
  label: 'Label',
  name: 'fieldName',
  required: true,
  position: 0,
  visible: true,
};

describe('Input Field', function() {
  const config = {
    ...defaultConfig,
    name: 'field1',
    required: true,
    className: 'field1',
    errorMessage: 'Invalid Value',
  };

  test(`default type => <Input .../>`, () => {
    const wrapper = shallow(<Input {...config} />);
    expect(wrapper.text()).toEqual('<SweetInput />');
    expect(wrapper.find('SweetInput').prop('type')).toEqual('text');
  });

  ['text', 'email', 'tel', 'numeric'].forEach(type => {
    test(`text => <Input type="${type}" .../>`, () => {
      const cnf = { ...config, type: type };
      const wrapper = shallow(<Input {...cnf} />);

      expect(wrapper.text()).toEqual('<SweetInput />');
      expect(wrapper.find('SweetInput').prop('type')).toEqual(type);
    });
  });

  test(`check the props for <Input .../>`, () => {
    const wrapper = shallow(<Input {...config} />);
    Object.keys(config).forEach(key => {
      expect(wrapper.find('SweetInput').prop(key)).toEqual(config[key]);
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
    choices: choices,
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
    choices: choices,
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
