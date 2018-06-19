// @flow
import React, { PureComponent } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import classnames from 'classnames';
import { ConsentControls } from './ConsentControls';
import ee from '../shared/pub_sub';
import { changeConsent } from '../state/consent';
import type { AppState } from '../state/reducers';
import './ConsentComponent.css';

type Props = {
  // active: if true, the component will be rendered.
  active: boolean,
  // hidden: indicates that the component, if rendered, needs to be hidden. it
  //   uses the `hidden-irrelevant` class to hide the component.
  hidden: boolean,
  // consented: the selected value for this form.
  consented: ?boolean,
  // variant: applied as a css class, used to style the input elements
  variant: string,
  // changeConsent: dispatches the change consent action.
  changeConsent: (value: boolean) => void,
};

class ConsentComponent extends PureComponent {
  props: Props;

  changeConsent = (consented: boolean) => {
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
    const { consented, active, hidden, variant } = this.props;
    if (!active) return null;

    const classNames = classnames('ConsentComponent', variant, {
      'hidden-irrelevant': hidden,
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
        {this.optOutWarning()}
        <div className="ConsentComponent--how-to-opt-out how-to-opt-out">
          <FormattedHTMLMessage id="consent.how_to_opt_out" />
        </div>
      </div>
    );
  }
}

const mapStateToProps = ({ member, consent }: AppState) => {
  const { consented, variant, isRequiredNew, isRequiredExisting } = consent;
  const active = (member && isRequiredExisting) || (!member && isRequiredNew);
  const hidden = !!member;

  return {
    active,
    hidden,
    consented,
    variant,
  };
};

const mapDispatchToProps = (dispatch: Dispatch) => ({
  changeConsent: (value: boolean) => dispatch(changeConsent(value)),
});

export default connect(mapStateToProps, mapDispatchToProps)(ConsentComponent);
