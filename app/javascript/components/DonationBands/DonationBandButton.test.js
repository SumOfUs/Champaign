import React from 'react';
import { mountWithIntl } from '../../../../spec/jest/intl-enzyme-test-helpers';
import DonationBandButton from './DonationBandButton';

describe('Featured Amount', function() {
  const onClick = jest.fn();

  it('highlights the Button if it is a featured amount ', () => {
    const wrapper = mountWithIntl(
      <DonationBandButton
        amount={3}
        featuredAmount={3}
        currency="GBP"
        onClick={onClick}
      />
    );
    const nodes = wrapper.find(DonationBandButton);
    expect(nodes.at(0).text()).toEqual('£3');
  });

  it('shades all amounts that do not match the featured amounts', () => {
    const wrapper = mountWithIntl(
      <DonationBandButton
        amount={5}
        featuredAmount={3}
        currency="USD"
        onClick={onClick}
      />
    );
    expect(
      wrapper
        .children()
        .first()
        .hasClass('DonationBandButton--shade')
    ).toBeTruthy();
  });
});
