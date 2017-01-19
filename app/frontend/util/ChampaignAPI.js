// @flow
import React from 'react';
import { FormattedMessage } from 'react-intl';
import $ from 'jquery';
import { camelizeKeys } from './util';

export type OperationResponse = {
  success: boolean;
  errors: {[id:string]: string[]};
}

const parseResponse = (response, textStatus, other): OperationResponse => {
  if(response === undefined) {
    return { success: true, errors: {} };
  }

  switch (response.status) {
    case 200:
    case 201:
    case 204:
      return { success: true, errors: {} };
    case 422:
      return { success: false, errors: camelizeKeys(response.responseJSON.errors) };
    default:
      return {
        success: false,
        errors: {
          base: [<FormattedMessage id="call_tool.errors.unknown" defaultMessage={`Unknown error, code ${response.code}`} />]
        }
      };
  }
};

const createCall = function(params: {pageId: string|number, memberPhoneNumber?: string, targetIndex: number}): Promise<OperationResponse> {
  const payload = {
    call: {
      member_phone_number: params.memberPhoneNumber,
      target_index: params.targetIndex
    }
  };

  return $.post(`/api/pages/${params.pageId}/call`, payload).then(parseResponse, parseResponse);
};

const ChampaignAPI = {
  calls: { create: createCall }
};

export default ChampaignAPI;
