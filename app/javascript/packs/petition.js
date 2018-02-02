import $ from 'jquery';
import ActionForm from '../member-facing/backbone/action_form';
import Petition from '../member-facing/backbone/petition';

const { personalization } = window.champaign; // convenience binding

chmp.mountPetition = function mountPetition(followUpUrl) {
  chmp.myActionForm = new ActionForm({
    akid: chmp.personalization.urlParams.akid,
    bucket: chmp.personalization.urlParams.bucket,
    location: chmp.personalization.location,
    member: chmp.personalization.member,
    outstandingFields: chmp.personalization.outstandingFields,
    prefill: true,
    referrer_id: chmp.personalization.urlParams.referrer_id,
    referring_akid: chmp.personalization.urlParams.referring_akid,
    rid: chmp.personalization.urlParams.rid,
    source: chmp.personalization.urlParams.source,
  });

  chmp.myPetition = new Petition({ followUpUrl });
};
