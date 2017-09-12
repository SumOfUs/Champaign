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
  },
  tracking_params: {
    country: string,
  },
};

export function sendEmail(params: SendEmailParams): Promise<OperationResponse> {
  const { page_id, ...payload } = params;

  return new Promise((resolve, reject) => {
    // FIXME: On 500 we're resolving, should be failing.
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
