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
};
const createCall = function(
  params: CreateCallParams
): Promise<OperationResponse> {
  const payload = {
    call: {
      member_phone_number: params.memberPhoneNumber,
      target_id: params.targetId,
    },
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
