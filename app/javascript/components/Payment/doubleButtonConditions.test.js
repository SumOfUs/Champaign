import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import DonateButton from '../DonateButton';

const disableSubmit = jest.fn();
const onClickHandle = jest.fn();

const currency = '$';
const donationAmount = 1;
const submitting = false;

let showMonthlyButton = (recurringDonor, recurringDefault) => {
  if (recurringDonor) {
    return false;
  } else {
    if (recurringDefault === 'only_one_off') {
      return false;
    }
    return true;
  }
};

let showOneOffButton = (recurringDonor, recurringDefault) => {
  if (recurringDonor) {
    return true;
  } else {
    if (recurringDefault === 'only_one_off') {
      return true;
    }

    if (recurringDefault === 'only_recurring') {
      return false;
    }
    return true;
  }
};

describe('Recurring Donors', () => {
  it(`shows one_off button for recurring donors when recurring_default is any`, () => {
    const recurringDonor = true;
    const recurring_default = 'only_recurring';
    let oneOffWrapper = null;

    if (showOneOffButton(recurringDonor, recurring_default)) {
      oneOffWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(toJson(oneOffWrapper)).toMatchSnapshot();
  });

  it(`doesn't show recurring button for recurring donors`, () => {
    const recurringDonor = true;
    const recurring_default = 'one_off';
    let recurringWrapper = null;

    if (showMonthlyButton(recurringDonor, recurring_default)) {
      recurringWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(recurringWrapper).toBeNull();
  });
});

describe('For one_off/non_donor/new_user donors when recurring default is one_off', () => {
  it(`shows one_off button`, () => {
    const recurringDonor = false;
    const recurring_default = 'one_off';
    let oneOffWrapper = null;

    if (showOneOffButton(recurringDonor, recurring_default)) {
      oneOffWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(toJson(oneOffWrapper)).toMatchSnapshot();
  });

  it(`shows recurring button`, () => {
    const recurringDonor = false;
    const recurring_default = 'one_off';
    let recurringWrapper = null;

    if (showMonthlyButton(recurringDonor, recurring_default)) {
      recurringWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(toJson(recurringWrapper)).toMatchSnapshot();
  });
});

describe('For one_off/non_donor/new_user donors when recurring default is recurring', () => {
  it(`shows one_off button`, () => {
    const recurringDonor = false;
    const recurring_default = 'recurring';
    let oneOffWrapper = null;

    if (showOneOffButton(recurringDonor, recurring_default)) {
      oneOffWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(toJson(oneOffWrapper)).toMatchSnapshot();
  });

  it(`shows recurring button`, () => {
    const recurringDonor = false;
    const recurring_default = 'recurring';
    let recurringWrapper = null;

    if (showMonthlyButton(recurringDonor, recurring_default)) {
      recurringWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(toJson(recurringWrapper)).toMatchSnapshot();
  });
});

describe('For one_off/non_donor/new_user donors when recurring default is only_one_off', () => {
  it(`shows one_off button`, () => {
    const recurringDonor = false;
    const recurring_default = 'only_one_off';
    let oneOffWrapper = null;

    if (showOneOffButton(recurringDonor, recurring_default)) {
      oneOffWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(toJson(oneOffWrapper)).toMatchSnapshot();
  });

  it(`doesn't show recurring button`, () => {
    const recurringDonor = false;
    const recurring_default = 'only_one_off';
    let recurringWrapper = null;

    if (showMonthlyButton(recurringDonor, recurring_default)) {
      recurringWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(recurringWrapper).toBeNull();
  });
});

describe('For one_off/non_donor/new_user donors when recurring default is only_recurring', () => {
  it(`doesn't show one_off button`, () => {
    const recurringDonor = false;
    const recurring_default = 'only_recurring';
    let oneOffWrapper = null;

    if (showOneOffButton(recurringDonor, recurring_default)) {
      oneOffWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(oneOffWrapper).toBeNull();
  });

  it(`shows recurring button`, () => {
    const recurringDonor = false;
    const recurring_default = 'only_recurring';
    let recurringWrapper = null;

    if (showMonthlyButton(recurringDonor, recurring_default)) {
      recurringWrapper = shallow(
        <DonateButton
          currency={currency}
          amount={donationAmount || 0}
          submitting={submitting}
          name="one_time"
          recurring={false}
          recurringDonor={recurringDonor}
          disabled={disableSubmit}
          onClick={onClickHandle}
        />
      );
    }

    expect(toJson(recurringWrapper)).toMatchSnapshot();
  });
});
