// @flow
import React, { PureComponent } from 'react';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import './ConsentControls.css';

type Props = {
  onChange: (consented: boolean) => void,
  consented: ?boolean,
  shortLabels?: boolean,
};

export class ConsentControls extends PureComponent {
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
      <div className="ConsentControls">
        <label className={acceptClass}>
          <input
            type="radio"
            name="consented"
            value={1}
            checked={consented === true}
            onChange={() => this.props.onChange(true)}
          />
          {shortLabels ? (
            <FormattedMessage id="consent.accept_short" defaultMessage="Yes" />
          ) : (
            <FormattedMessage
              id="consent.accept_long"
              defaultMessage="Yes – sign and receive emails"
            />
          )}
        </label>
        <label className={declineClass}>
          <input
            type="radio"
            name="consented"
            value={0}
            checked={consented === false}
            onChange={() => this.props.onChange(false)}
          />
          {shortLabels ? (
            <FormattedMessage id="consent.decline_short" defaultMessage="No" />
          ) : (
            <FormattedMessage
              id="consent.decline_long"
              defaultMessage="No – sign, but don't receive emails"
            />
          )}
        </label>
      </div>
    );
  }
}
