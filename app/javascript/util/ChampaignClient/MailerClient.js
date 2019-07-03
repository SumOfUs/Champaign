import $ from 'jquery';
import { parseResponse } from './Base';

export function sendEmail(params) {
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
