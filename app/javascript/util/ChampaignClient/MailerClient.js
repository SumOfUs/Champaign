// @flow
import { parseResponse } from './Base';
import type { OperationResponse } from './Base';

type SendEmailParams = {
  body: string,
  subject: string,
  page_id: string,
  from_name: string,
  from_email: string,
  to_name: string,
  to_email: string,
};

export function sendEmail(params: SendEmailParams): Promise<OperationResponse> {
  const { page_id, ...email } = params;

  return new Promise((resolve, reject) => {
    $.post(`/api/pages/${page_id}/email`, { email })
      .done(response => resolve(parseResponse(response)))
      .fail(response => reject(parseResponse(response)));
  });
}

export default {
  sendEmail,
};
