// @flow
import $ from 'jquery';
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import classnames from 'classnames';
import { ConsentControls } from './ConsentControls';
import { changeConsent } from '../state/consent';
import type { AppState } from '../state/reducers';
import './ConsentComponent.css';

type Props = {
  isNewMember: boolean,
  isRequired: boolean,
  consented: ?boolean,
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

  componentDidUpdate() {
    $.publish('sidebar:height_change');
  }

  render() {
    const { consented, isRequired, isNewMember, variant } = this.props;
    if (!isRequired) return null;

    const classNames = classnames('ConsentComponent', variant, {
      'hidden-irrelevant': !isNewMember,
    });

    return (
      <div className={classNames}>
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

const mapStateToProps = ({ member, consent }: AppState) => ({
  isNewMember: !member,
  isRequired: consent.isRequired,
  consented: consent.consented,
  variant: consent.variant,
});
export default connect(mapStateToProps)(ConsentComponent);
