import pick from 'lodash/pick';

// 'https://sls.sumofus.org/parliament-data/mps'
const url = 'https://nhk8yso3sk.execute-api.us-east-1.amazonaws.com/dev/mps';
export const search = async postcode => {
  const result = await fetch(`${url}/${postcode}`, {
    method: 'post',
    headers: {
      'content-type': 'application/json',
    },
  })
    .then(r => r.json())
    .then(data => {
      console.log(data);
      if (data.errors) throw data;
      return data;
    });

  return result;
};

export const sendEmail = async params => {
  const data = {
    email: {
      body: params.body,
      recipients: params.recipients,
      subject: params.subject,
      country: params.country,
      from_name: params.sender.name,
      from_email: params.sender.email,
      email_service: params.emailService,
      clicked_copy_body_button: params.clickedCopyBodyButton,
      consented: params.consented,
    },
    tracking_params: pick(
      window.champaign.personalization.urlParams,
      'source',
      'akid',
      'referring_akid',
      'referrer_id',
      'rid'
    ),
  };

  const result = await fetch(`/api/pages/${params.pageId}/action_emails`, {
    method: 'post',
    headers: {
      'content-type': 'application/json',
    },
    body: JSON.stringify(data),
  })
    .then(r => r.json())
    .then(data => {
      if (data.errors) throw data;
      return data;
    });

  return result;
};
