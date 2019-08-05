import pick from 'lodash/pick';
export const search = async postcode => {
  const result = await fetch('https://sls.sumofus.org/parliament-data/mps', {
    method: 'post',
    headers: {
      'content-type': 'application/json',
    },
    body: JSON.stringify({ postcode }),
  })
    .then(r => r.json())
    .then(data => {
      if (data.errors) throw data;
      return data;
    });

  return result;
};

export const sendEmail = async params => {
  const data = {
    recipient: params.recipient,
    email: {
      body: params.body,
      subject: params.subject,
      country: params.country,
      from_name: params.sender.name,
      from_email: params.sender.email,
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
