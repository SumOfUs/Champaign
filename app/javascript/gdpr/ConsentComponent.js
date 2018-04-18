// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import classnames from 'classnames';
import { GDPRConsentControls } from './GDPRConsentControls';
import { changeConsent } from '../state/gdpr';
import type { AppState } from '../state/reducers';
import './ConsentComponent.css';

type Props = {
  hidden: boolean,
  consented: ?boolean,
  variant: string,
  dispatch: (action: any) => void,
};

class ConsentComponent extends Component {
  props: Props;

  changeConsent = (consented: boolean) => {
    this.props.dispatch(changeConsent(consented));
  };

  render() {
    const { consented, hidden, variant } = this.props;
    if (hidden) return null;

    const controlsClass = classnames('ConsentComponent--prompt', variant);

    return (
      <div className="ConsentComponent">
        <div className="ConsentComponent--opt-in-reason opt-in-reason">
          <FormattedHTMLMessage id="gdpr.opt_in_reason" defaultMessage="hi" />
        </div>
        <div className={controlsClass}>
          <GDPRConsentControls
            consented={consented}
            onChange={this.changeConsent}
            shortLabels={variant === 'simple'}
          />
        </div>
        <div className="ConsentComponent--how-to-opt-out how-to-opt-out">
          <FormattedHTMLMessage id="gdpr.how_to_opt_out" defaultMessage="hi" />
        </div>
      </div>
    );
  }
}

const mapStateToProps = ({ gdpr }: AppState) => ({
  hidden: gdpr.previosulyConsented || !gdpr.isEU,
  consented: gdpr.consented,
  variant: gdpr.variant,
  memberId: gdpr.memberId,
  email: gdpr.email,
});
export default connect(mapStateToProps)(ConsentComponent);
