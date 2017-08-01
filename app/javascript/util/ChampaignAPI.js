// @flow
import React from 'react';
import { FormattedMessage } from 'react-intl';
import $ from 'jquery';
import { camelizeKeys } from './util';

export type OperationResponse = {
  success: boolean,
  errors: { [id: string]: any[] },
};

const parseResponse = (response): OperationResponse => {
  if (response === undefined) {
    return { success: true, errors: {} };
  }

  switch (response.status) {
    case 200:
    case 201:
    case 204:
      return { success: true, errors: {} };
    case 422:
      return {
        success: false,
        errors: camelizeKeys(response.responseJSON.errors),
      };
    default:
      return {
        success: false,
        errors: {
          base: [
            <FormattedMessage
              id="call_tool.errors.unknown"
              defaultMessage={`Unknown error, code ${response.code}`}
            />,
          ],
        },
      };
  }
};

type CreateCallParams = {
  pageId: string | number,
  memberPhoneNumber?: string,
  targetId: string,
  trackingParams: any,
};
const createCall = function(
  params: CreateCallParams
): Promise<OperationResponse> {
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

const ChampaignAPI = {
  calls: { create: createCall },
};

export default ChampaignAPI;
