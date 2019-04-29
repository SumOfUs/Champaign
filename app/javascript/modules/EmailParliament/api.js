// @flow
import type { Target } from './index';
import pick from 'lodash/pick';
export const search = async (postcode: ?string) => {
  const result: Target = await fetch(
    'https://sls.sumofus.org/parliament-data/mps',
    {
      method: 'post',
      headers: {
        'content-type': 'application/json',
      },
      body: JSON.stringify({ postcode }),
    }
  )
    .then(r => r.json())
    .then(data => {
      if (data.errors) throw data;
      return data;
    });

  return result;
};

type SendEmailParams = {
  pageId: string,
  recipient: {
    name: string,
    email: string,
  },
  sender: {
    name: string,
    email: string,
  },
  subject: string,
  body: string,
  country: string,
};

type SendEmailPayload = {
  recipient: {
    name: string,
    email: string,
  },
  email: {
    body: string,
    from_name: string,
    from_email: string,
    subject: string,
    country: string,
  },
  tracking_params: { [key: string]: string },
  consented?: boolean,
};

export const sendEmail = async (params: SendEmailParams) => {
  const data: SendEmailPayload = {
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

  const result: Target = await fetch(
    `/api/pages/${params.pageId}/action_emails`,
    {
      method: 'post',
      headers: {
        'content-type': 'application/json',
      },
      body: JSON.stringify(data),
    }
  )
    .then(r => r.json())
    .then(data => {
      if (data.errors) throw data;
      return data;
    });

  return result;
};
