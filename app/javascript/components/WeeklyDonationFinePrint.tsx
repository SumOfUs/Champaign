import * as React from 'react';
import { FormattedHTMLMessage } from 'react-intl';

const WeeklyDonationFinePrint = props => {
  const className = props.className || 'ReCaptchaBranding';

  return (
    <p className={className}>
      <FormattedHTMLMessage
        id="fundraiser.weekly_donation_fineprint"
        defaultMessage="To reduce processing fees and make sure you donation has as much impact as possible, weekly donations are processed once per month."
      />
    </p>
  );
};

export default WeeklyDonationFinePrint;
