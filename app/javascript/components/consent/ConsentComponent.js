import React, { PureComponent } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import classnames from 'classnames';
import { ConsentControls } from './ConsentControls';
import ee from '../../shared/pub_sub';
import { changeConsent } from '../../state/consent';
import './ConsentComponent.css';

class ConsentComponent extends PureComponent {
  changeConsent = consented => {
    this.props.changeConsent(consented);
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
    ee.emit('sidebar:height_change');
  }

  optOutWarning() {
    if (this.props.consented !== false) return;
    return (
      <div className="ConsentComponent--opt-out-warn">
        <h5 className="ConsentComponent--opt-out-warn-title">
          <FormattedHTMLMessage id="consent.opt_out_warn_title" />
        </h5>
        <p className="ConsentComponent--opt-out-warn-message">
          <FormattedHTMLMessage id="consent.opt_out_warn_message" />
        </p>
      </div>
    );
  }

  render() {
    const {
      alwaysShow,
      consented,
      active,
      hidden,
      isRequired,
      variant,
      showConsentRequired,
    } = this.props;
    if (!active && !isRequired) return null;

    const classNames = classnames('ConsentComponent', variant, {
      'hidden-irrelevant': alwaysShow ? false : hidden,
    });

    return (
      <div className={classNames}>
        <div className={classnames('ConsentComponent--prompt', variant)}>
          <ConsentControls
            consented={consented}
            onChange={this.changeConsent}
            shortLabels={this.shortLabels()}
            showConsentRequired={showConsentRequired}
          />
        </div>
        {this.optOutWarning()}
        <div className="ConsentComponent--how-to-opt-out how-to-opt-out">
          <FormattedHTMLMessage id="consent.how_to_opt_out" />
        </div>
      </div>
    );
  }
}

const mapStateToProps = ({ member, consent }) => {
  const {
    consented,
    variant,
    isRequiredNew,
    isRequiredExisting,
    showConsentRequired,
  } = consent;
  const active = (member && isRequiredExisting) || (!member && isRequiredNew);
  const hidden = !!member;
  return {
    active,
    hidden,
    consented,
    variant,
    showConsentRequired,
  };
};

const mapDispatchToProps = dispatch => ({
  changeConsent: value => dispatch(changeConsent(value)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ConsentComponent);
