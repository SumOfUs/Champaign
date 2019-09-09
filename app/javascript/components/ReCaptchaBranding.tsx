import * as React from 'react';
import { FormattedHTMLMessage } from 'react-intl';

const ReCaptchaBranding = () => (
  <p className="ReCaptchaBranding">
    <FormattedHTMLMessage
      id="recaptcha_branding_html"
      defaultMessage={
        <p>
          {'This site is protected by reCAPTCHA and the Google '}
          <a href="https://policies.google.com/privacy">Privacy Policy </a>
          {' and '}
          <a href="https://policies.google.com/terms">Terms of Service</a>
          {' apply.'}
        </p>
      }
    />
  </p>
);

export default ReCaptchaBranding;
