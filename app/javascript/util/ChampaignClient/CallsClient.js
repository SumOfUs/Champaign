import { parseResponse } from './Base';
import type { OperationResponse } from './Base';

type CreateCallParams = {
  pageId: string | number,
  memberPhoneNumber?: string,
  targetId: string,
  trackingParams: any,
};

const create = function(params: CreateCallParams): Promise<OperationResponse> {
  const inner = {};
  inner.member_phone_number = params.memberPhoneNumber;
  if (!!params.targetPhoneExtension)
    inner.target_phone_extension = params.targetPhoneExtension;
  if (!!params.targetPhoneNumber)
    inner.target_phone_number = params.targetPhoneNumber;
  if (!!params.targetTitle) inner.target_title = params.targetTitle;
  if (!!params.targetName) inner.target_name = params.targetName;
  if (!!params.checksum) inner.checksum = params.checksum;
  if (!!params.targetId) inner.target_id = params.targetId;

  const payload = {
    call: inner,
    ...params.trackingParams,
  };

  return new Promise((resolve, reject) => {
    $.post(`/api/pages/${params.pageId}/call`, payload)
      .done(response => resolve(parseResponse(response)))
      .fail(response => reject(parseResponse(response)));
  });
};

const CallsClient = {
  create: create,
};

export default CallsClient;
