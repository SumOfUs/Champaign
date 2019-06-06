// @flow
import React, { PureComponent } from 'react';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import './ConsentControls.css';

type Props = {
  onChange: (consented: boolean) => void,
  consented: ?boolean,
  shortLabels?: boolean,
  showConsentRequired?: boolean,
};

export class ConsentControls extends PureComponent<Props> {
  render() {
    const { shortLabels, consented, showConsentRequired } = this.props;
    const wrapperClass = classnames('ConsentControls', {
      warning: showConsentRequired,
    });
    const acceptClass = classnames({
      active: consented === true,
    });
    const declineClass = classnames({
      active: consented === false,
    });

    return (
      <div className={wrapperClass}>
        <p className="notice">
          <FormattedMessage
            id="consent.select_an_option"
            defaultMessage="Please select an option"
          />
        </p>
        <label className={acceptClass}>
          <input
            type="radio"
            name="consented"
            value={1}
            checked={consented === true}
            onChange={() => this.props.onChange(true)}
          />
          <FormattedMessage id="consent.accept" defaultMessage="Yes" />
        </label>
        <label className={declineClass}>
          <input
            type="radio"
            name="consented"
            value={0}
            checked={consented === false}
            onChange={() => this.props.onChange(false)}
          />
          <FormattedMessage id="consent.decline" defaultMessage="No" />
        </label>
      </div>
    );
  }
}
