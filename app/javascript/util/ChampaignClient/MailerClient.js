// @flow
import { parseResponse } from './Base';
import type { OperationResponse } from './Base';

type SendEmailParams = {
  body: string,
  subject: string,
  pageId: string,
  from_name: string,
  from_email: string,
  to_name: string,
  to_email: string,
};

export function sendEmail(
  emailParams: SendEmailParams,
  trackingParams: any = {}
): Promise<OperationResponse> {
  const payload = {
    email: emailParams,
    ...trackingParams,
  };

  return new Promise((resolve, reject) => {
    $.post(`/api/pages/${emailParams.pageId}/email`, payload)
      .done(response => resolve(parseResponse(response)))
      .fail(response => reject(parseResponse(response)));
  });
}

export default {
  sendEmail,
};
