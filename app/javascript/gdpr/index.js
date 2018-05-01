import React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';
import ConsentComponent from './ConsentComponent';

import {
  setPreviouslyConsented,
  changeCountry,
  changeMemberEmail,
  changeMemberId,
  changeVariant,
} from '../state/gdpr';

// TODO: Listen for member ID (new members)
export default function GDPRConsentComponent(options) {
  if (!options) {
    throw new Error(
      'GDPRConsentComponent must be initialized with an options object'
    );
  }
  const store = window.champaign.store;
  const member = window.champaign.personalization.member;
  const variant = options.variant;
  const $countrySelect = $('.petition-bar__main select[name=country]');
  const $emailInput = $('.petition-bar__main input[name=email]');

  // set member id, and email
  if (member) {
    store.dispatch(setPreviouslyConsented(member.consented));
    store.dispatch(changeMemberEmail(member.email));
    store.dispatch(changeMemberId(member.id));
    store.dispatch(changeCountry(member.country));
  }

  if (options.variant) store.dispatch(changeVariant(options.variant));

  // listen for changes to country
  $countrySelect.on('change', () =>
    store.dispatch(changeCountry($countrySelect.val() || null))
  );

  // listen for changes to email
  $emailInput.on('change', () =>
    store.dispatch(changeMemberEmail($emailInput.val() || null))
  );

  render(
    <ComponentWrapper store={window.champaign.store} locale={'en'}>
      <ConsentComponent />
    </ComponentWrapper>,
    options.container
  );
}
