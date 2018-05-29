// @flow
import React, { Component } from 'react';
import Backbone from 'backbone';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import Popup from 'reactjs-popup';
import { connect } from 'react-redux';
import Button from '../components/Button/Button';
import { changeConsent, toggleModal } from '../state/consent';
import './ExistingMemberConsent.css';

import type { Member } from '../state/member/reducer';

const style = {
  width: 'auto',
  padding: 30,
};

type Props = {
  open: boolean,
  isRequired: boolean,
  member: Member,
  toggleModal: boolean => void,
  changeConsent: boolean => void,
};

class ExistingMemberConsent extends Component {
  props: Props;

  closeModal = () => this.props.toggleModal(false);

  submit = (value?: boolean) => {
    if (value) this.props.changeConsent(value);
    Backbone.trigger('form:submit_action_form');
    this.closeModal();
  };

  render() {
    if (!this.props.member || !this.props.isRequired) return null;
    return (
      <Popup
        open={this.props.open}
        onClose={this.closeModal}
        closeOnDocumentClick
        contentStyle={style}
      >
        <div className="ExistingMemberConsent">
          <div className="ExistingMemberConsent--opt-in-reason">
            <FormattedHTMLMessage id="consent.existing.opt_in_reason" />
          </div>
          <Button
            className="ExistingMemberConsent--accept"
            onClick={() => this.submit(true)}
          >
            <FormattedMessage id="consent.accept_short" defaultMessage="Yes" />
          </Button>
          <Button
            className="ExistingMemberConsent--decline"
            onClick={() => this.submit()}
          >
            <FormattedMessage
              id="consent.existing.decline"
              defaultMessage="Not right now"
            />
          </Button>
          <div className="ExistingMemberConsent--how-to-opt-out">
            <FormattedHTMLMessage id="consent.how_to_opt_out" />
          </div>
        </div>
      </Popup>
    );
  }
}

const mapStateToProps = (state: AppState) => ({
  open: state.consent.modalOpen,
  isRequired: state.consent.isRequired,
  member: state.member,
});

const mapDispatchToProps = (dispatch: Dispatch) => ({
  toggleModal: (value: boolean) => dispatch(toggleModal(value)),
  changeConsent: (value: boolean) => dispatch(changeConsent(value)),
});

export default connect(mapStateToProps, mapDispatchToProps)(
  ExistingMemberConsent
);
