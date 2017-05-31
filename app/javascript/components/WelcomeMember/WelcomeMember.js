/* @flow
 * Description
 * ===========
 * This small widget displays the member's name and a link to reset the member
 * if it isn't them. I'm using fa-icons for now, so it's not self-contained
 * which means we should eventually refactor this once we've moved all components
 * to react.
 *
 * PREVIOUS MARKUP
 * ===============
 * <div class="action-form__welcome-text">
 *   <i class="fa fa-check-square-o fundraiser-bar__user-icon"></i>
 *   <span class="action-form__welcome-name">John Doe</span> <br>
 *   <a href="javascript:;" class=" action-form__clear-form">Not you?</a>
 * </div>
 */
import React  from 'react';
import { FormattedMessage } from 'react-intl';

import type { Member } from '../../state';

import './WelcomeMember.css';

type OwnProps = {
  member: Member,
  resetMember: () => void;
};

export default function WelcomeMember(props: OwnProps) {
  if (!props.member || (!props.member.name && !props.member.email)) return null;

  return (
    <div className="WelcomeMember">
      <i className="WelcomeMember__icon fa fa-check-square-o" />
      <div>
        <span className="WelcomeMember__name">{props.member.name || props.member.email}</span>
        <a className="WelcomeMember__link" onClick={props.resetMember}>
          <FormattedMessage id="form.switch_user" />
        </a>
      </div>
    </div>
  );
}
