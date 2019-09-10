import * as React from 'react';
import { FormattedHTMLMessage } from 'react-intl';

const ReCaptchaBranding = () => (
  <p className="ReCaptchaBranding">
    <FormattedHTMLMessage
      id="recaptcha_branding_html"
      defaultMessage="This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply."
    />
  </p>
);

export default ReCaptchaBranding;
