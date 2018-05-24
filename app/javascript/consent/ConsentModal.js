// @flow
import React, { Component } from 'react';
import Backbone from 'backbone';
import { FormattedMessage } from 'react-intl';
import Popup from 'reactjs-popup';
import { connect } from 'react-redux';
import { changeConsent, toggleModal } from '../state/consent';

const mapStateToProps = state => ({
  open: state.consent.modalOpen,
  member: state.member,
});

const mapDispatchToProps = dispatch => ({
  toggleModal: (value: boolean) => dispatch(toggleModal(value)),
  changeConsent: (value: boolean) => dispatch(changeConsent(value)),
});

export default connect(mapStateToProps, mapDispatchToProps)(
  class ConsentModal extends Component {
    closeModal = () => this.props.toggleModal(false);

    giveConsent = () => {
      this.props.changeConsent(true);
      Backbone.trigger('form:submit_action_form');
      this.closeModal();
    };

    render() {
      if (!this.props.member) return null;
      return (
        <Popup
          open={this.props.open}
          closeOnDocumentClick
          onClose={this.closeModal}
        >
          <div>
            <button onClick={this.giveConsent}>Yes</button>
          </div>
        </Popup>
      );
    }
  }
);
