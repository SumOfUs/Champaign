import React from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import $ from 'jquery';
import { camelizeKeys } from './util';

export type OperationResponse = {
  success: boolean,
  errors: ?{[id:string]: string[]}
}

const parseResponse = (response):OperationResponse => {
  if(response === undefined) {
    return { success: true, errors: {} };
  }

  switch (response.status) {
    case 200:
    case 201:
    case 204:
      return { success: true, errors: {} };
    case 422:
      return { sucess: false, errors: camelizeKeys(response.responseJSON.errors) };
    default:
      return {
        sucess: false,
        errors: {
          base: [<FormattedMessage id="call_tool.errors.unknown" defaultMessage={`Unknown error, code ${response.code}`} />]
        }
      };
  }
};


const createCall = function(params: {pageId: string, memberPhoneNumber: string, targetIndex: string}) {
  const payload = {
    call: {
      member_phone_number: params.memberPhoneNumber,
      target_index: params.targetIndex
    }
  };

  return new Promise((resolve, reject) => {
    $.post(`/api/pages/${params.pageId}/call`, payload)
    .done(response => {
      resolve(parseResponse(response));
    }).fail(response => {
      reject(parseResponse(response));
    });
  });
};

const ChampaignAPI = {
  calls: { create: createCall }
};

export default ChampaignAPI;
