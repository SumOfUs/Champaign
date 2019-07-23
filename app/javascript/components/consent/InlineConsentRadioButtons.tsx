import * as React from 'react';
import { FormattedHTMLMessage } from 'react-intl';
import { useSelector } from 'react-redux';
import { IAppState } from '../../types';
import { ConsentControls } from './ConsentControls';

interface IProps {
  consent: boolean;
  highlight?: boolean;
  onChange?: (value: boolean) => void;
}

export default function InlineConsentRadiobuttons(props: IProps) {
  const member = useSelector((state: IAppState) => state.member);
  if (member && member.email) {
    return null;
  }

  const displayWarning = () => (
    <div className="ConsentComponent--opt-out-warn">
      <h5 className="ConsentComponent--opt-out-warn-title">
        <FormattedHTMLMessage id="consent.opt_out_warn_title" />
      </h5>
      <p className="ConsentComponent--opt-out-warn-message">
        <FormattedHTMLMessage id="consent.opt_out_warn_message" />
      </p>
    </div>
  );

  return (
    <div className="ConsentComponent simple">
      <div className="ConsentComponent--prompt simple">
        <ConsentControls
          consented={props.consent}
          onChange={props.onChange}
          showConsentRequired={props.highlight}
        />
      </div>
      {props.consent === false && displayWarning()}
      <div className="ConsentComponent--how-to-opt-out how-to-opt-out">
        <FormattedHTMLMessage id="consent.how_to_opt_out" />
      </div>
    </div>
  );
}
