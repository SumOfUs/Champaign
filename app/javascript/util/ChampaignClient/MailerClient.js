// @flow
import { parseResponse } from './Base';
import type { OperationResponse } from './Base';

type SendEmailParams = {
  page_id: string,
  email: {
    body: string,
    subject: string,
    from_name: string,
    from_email: string,
    target_id: string,
    country: string,
  },
  tracking_params: { [key: string]: string },
};

export function sendEmail(params: SendEmailParams): Promise<OperationResponse> {
  const { page_id, ...payload } = params;

  return new Promise((resolve, reject) => {
    $.post(`/api/pages/${page_id}/emails`, payload)
      .done((data, textStatus, jqXHR) => {
        resolve(parseResponse(jqXHR));
      })
      .fail((jqXHR, textStatus, errorThrown) => {
        reject(parseResponse(jqXHR));
      });
  });
}

export default {
  sendEmail,
};
