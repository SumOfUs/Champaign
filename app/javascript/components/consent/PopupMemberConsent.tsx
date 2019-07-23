import * as React from 'react';
import { FormattedHTMLMessage, FormattedMessage } from 'react-intl';
import { useSelector } from 'react-redux';
import Popup from 'reactjs-popup';
import consent from '../../modules/consent/consent';
import { IAppState } from '../../types';
import Button from '../Button/Button';
import './ExistingMemberConsent.css';

interface IProps {
  open: boolean;
  countryCode: string;
  toggleModal: (value: boolean) => void;
  onSubmit: (value: boolean) => void;
}
export default function PopupMemberConsent(props: IProps) {
  const member = useSelector((state: IAppState) => state.member);
  const onClose = () => props.toggleModal(false);
  const onConsent = e => {
    e.preventDefault();
    props.onSubmit(true);
  };
  const onDeny = e => {
    e.preventDefault();
    props.onSubmit(false);
  };

  if (!member || !consent.isRequired(props.countryCode, member)) {
    return null;
  }
  return (
    <Popup
      open={props.open}
      onClose={onClose}
      closeOnDocumentClick={true}
      contentStyle={{ width: 'auto', padding: 30 }}
    >
      <div className="ExistingMemberConsent">
        <div className="ExistingMemberConsent--opt-in-reason">
          <FormattedHTMLMessage id="consent.existing.opt_in_reason" />
        </div>
        <Button className="ExistingMemberConsent--accept" onClick={onConsent}>
          <FormattedMessage id="consent.existing.accept" defaultMessage="Yes" />
        </Button>
        <Button className="ExistingMemberConsent--decline" onClick={onDeny}>
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
