import { parseResponse } from './Base';
import captcha from '../../shared/recaptcha';

const create = async function(params) {
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
    'g-recaptcha-response': params.recaptchaToken,
  };

  return new Promise((resolve, reject) => {
    $.post(`/api/pages/${params.pageId}/call`, payload)
      .done((data, textStatus, jqXHR) => {
        resolve(parseResponse(jqXHR));
      })
      .fail((jqXHR, textStatus, errorThrown) => {
        reject(parseResponse(jqXHR));
      });
  });
};

const CallsClient = {
  create: create,
};

export default CallsClient;
