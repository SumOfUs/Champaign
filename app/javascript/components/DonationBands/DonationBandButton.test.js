import React from 'react';
import { mount } from 'enzyme';
import { IntlProvider } from 'react-intl';
import { translations } from 'champaign-i18n';
import DonationBandButton from './DonationBandButton';

describe('Featured Amount', function() {
  const onClick = jest.fn();

  it('highlights the Button if it is a featured amount ', () => {
    const wrapper = mount(
      <IntlProvider locale="en" messages={translations.en}>
        <DonationBandButton
          amount={3}
          featuredAmount={3}
          currency="GBP"
          onClick={onClick}
        />
      </IntlProvider>
    );
    const nodes = wrapper.find(DonationBandButton);
    expect(nodes.at(0).text()).toEqual('£3');
  });

  it('shades all amounts that do not match the featured amounts', () => {
    const wrapper = mount(
      <IntlProvider locale="en" messages={translations.en}>
        <DonationBandButton
          amount={5}
          featuredAmount={3}
          currency="USD"
          onClick={onClick}
        />
      </IntlProvider>
    );
    const nodes = wrapper.find(DonationBandButton);
    expect(nodes.at(0).hasClass('DonationBandButton--shade')).toBeTruthy();
  });
});
