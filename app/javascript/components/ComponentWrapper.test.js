import React from 'react';
import { shallow, mount } from 'enzyme';
import { FormattedMessage } from 'react-intl';
import configureStore from '../state';
import toJson from 'enzyme-to-json';
import ComponentWrapper from './ComponentWrapper';

describe('Snapshots:', () => {
  test('With custom messages object', () => {
    const wrapper = shallow(
      <ComponentWrapper locale="en" messages={{}}>
        Test
      </ComponentWrapper>
    );
    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('With default messages object', () => {
    const wrapper = shallow(
      <ComponentWrapper locale="en">Test</ComponentWrapper>
    );
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});

describe('Store', () => {
  const store = configureStore();

  test('Wraps the component in a redux Provider if given a store', () => {
    const wrapper = mount(
      <ComponentWrapper locale="en" store={store}>
        Should be wrapped in a store
      </ComponentWrapper>
    );
    const provider = wrapper.find('Provider');
    expect(provider.prop('store')).toEqual(store);
    expect(provider.text()).toBe('Should be wrapped in a store');
  });

  test('Does create a Provider if no store is passed', () => {
    const wrapper = mount(<ComponentWrapper locale="en">...</ComponentWrapper>);
    const provider = wrapper.find('Provider');
    expect(provider.length).toBe(0);
  });
});

describe('Optimizely hook', () => {
  test('Call optimizely hook on componentDidMount', () => {
    const optimizelyHook = jest.fn();
    mount(
      <ComponentWrapper optimizelyHook={optimizelyHook} locale="en">
        Test
      </ComponentWrapper>
    );
    expect(optimizelyHook).toHaveBeenCalledTimes(1);
  });

  test('Call optimizely hook on componentDidUpdate', () => {
    const optimizelyHook = jest.fn();
    const wrapper = mount(
      <ComponentWrapper optimizelyHook={optimizelyHook} locale="en">
        Test
      </ComponentWrapper>
    );
    wrapper.setProps({ children: 'Updated test' });
    wrapper.update();
    expect(optimizelyHook).toHaveBeenCalledTimes(2);
  });
});

describe('IntlProvider', () => {
  const messages = {
    greeting: 'Bon jour',
  };

  test('Translating nested children correctly', () => {
    const wrapper = mount(
      <ComponentWrapper locale="fr" messages={messages}>
        <FormattedMessage id="greeting" />
      </ComponentWrapper>
    );
    expect(wrapper.text()).toBe('Bon jour');
  });
});
