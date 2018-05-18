// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import classnames from 'classnames';
import { ConsentControls } from './ConsentControls';
import { changeConsent } from '../state/consent';
import type { AppState } from '../state/reducers';
import './ConsentComponent.css';

type Props = {
  hidden: boolean,
  consented: ?boolean,
  doubleOptIn: boolean,
  variant: string,
  dispatch: (action: any) => void,
};

class ConsentComponent extends Component {
  props: Props;

  changeConsent = (consented: boolean) => {
    this.props.dispatch(changeConsent(consented));
  };

  shortLabels() {
    switch (this.props.variant) {
      case 'simple':
        return true;
      default:
        return false;
    }
  }
  render() {
    const { consented, hidden, variant } = this.props;
    if (hidden) return null;
    return (
      <div className={classnames('ConsentComponent', variant)}>
        <div className="ConsentComponent--opt-in-reason opt-in-reason">
          <FormattedHTMLMessage id="consent.opt_in_reason" />
        </div>
        <div className={classnames('ConsentComponent--prompt', variant)}>
          <ConsentControls
            consented={consented}
            onChange={this.changeConsent}
            shortLabels={this.shortLabels()}
          />
        </div>
        {consented === false && (
          <div className="ConsentComponent--opt-out-warn">
            <h5 className="ConsentComponent--opt-out-warn-title">
              <FormattedHTMLMessage id="consent.opt_out_warn_title" />
            </h5>
            <p className="ConsentComponent--opt-out-warn-message">
              <FormattedHTMLMessage id="consent.opt_out_warn_message" />
            </p>
          </div>
        )}
        <div className="ConsentComponent--how-to-opt-out how-to-opt-out">
          <FormattedHTMLMessage id="consent.how_to_opt_out" />
        </div>
      </div>
    );
  }
}

const mapStateToProps = ({ consent }: AppState) => ({
  hidden: consent.isDoubleOptIn || consent.previosulyConsented || !consent.isEU,
  doubleOptIn: consent.isDoubleOptIn,
  consented: consent.consented,
  variant: consent.variant,
  memberId: consent.memberId,
  email: consent.email,
});
export default connect(mapStateToProps)(ConsentComponent);
