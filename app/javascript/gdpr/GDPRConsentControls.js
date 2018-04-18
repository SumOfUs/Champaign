// @flow
import React, { PureComponent } from 'react';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import './GDPRConsentControls.css';

type Props = {
  onChange: (consented: boolean) => void,
  consented: ?boolean,
  shortLabels?: boolean,
};

export class GDPRConsentControls extends PureComponent {
  props: Props;
  render() {
    const { shortLabels, consented } = this.props;
    const acceptClass = classnames({
      active: consented === true,
    });
    const declineClass = classnames({
      active: consented === false,
    });
    return (
      <div className="GDPRConsentControls">
        <label className={acceptClass}>
          <input
            type="radio"
            name="user_consented"
            value={true}
            checked={consented === true}
            onChange={() => this.props.onChange(true)}
          />
          {shortLabels ? (
            <FormattedMessage id="gdpr.accept_short" defaultMessage="Yes" />
          ) : (
            <FormattedMessage
              id="gdpr.accept_long"
              defaultMessage="Yes – sign and receive emails"
            />
          )}
        </label>
        <label className={declineClass}>
          <input
            type="radio"
            name="user_consented"
            checked={consented === false}
            onChange={() => this.props.onChange(false)}
          />
          {shortLabels ? (
            <FormattedMessage id="gdpr.decline_short" defaultMessage="No" />
          ) : (
            <FormattedMessage
              id="gdpr.decline_long"
              defaultMessage="No – sign, but don't receive emails"
            />
          )}
        </label>
      </div>
    );
  }
}
