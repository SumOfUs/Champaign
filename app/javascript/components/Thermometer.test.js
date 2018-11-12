import React from 'react';
import renderer from 'react-test-renderer';
import { IntlProvider } from 'react-intl';
import Thermometer from './Thermometer';

test('Renders as expected', () => {
  const component = renderer.create(
    <IntlProvider locale="en-GB" messages={{}}>
      <Thermometer donations={1000} goal={600000} currencyCode={'GBP'} />
    </IntlProvider>
  );

  expect(component.toJSON()).toMatchSnapshot();
});
