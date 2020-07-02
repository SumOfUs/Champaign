import { camelCase, mapKeys, mapValues } from 'lodash';

export function camelizeKeys(obj) {
  if (!obj) return obj;
  if (Array.isArray(obj)) return obj.map(v => camelizeKeys(v));
  if (typeof obj === 'object') {
    const camelCased = mapKeys(obj, (v, k) => camelCase(k));
    return mapValues(camelCased, v => camelizeKeys(v));
  }
  return obj;
}

export function convertHtmlToPlainText(htmlValue) {
  let htmlElement = document.createElement('div');
  htmlElement.innerHTML = htmlValue;
  return htmlElement.textContent || htmlElement.innerText || '';
} //Should move this to Utils once feature is done

export function copyToClipboard(content) {
  const htmlElement = document.createElement('textarea');
  htmlElement.value = content;
  document.body.appendChild(htmlElement);
  htmlElement.select();
  document.execCommand('copy');
  document.body.removeChild(htmlElement);
}

export function composeEmailLink(email) {
  const target_email = encodeURIComponent(email.targetEmail);
  const subject = encodeURIComponent(email.subject);
  const body = encodeURIComponent(email.body);
  let host, urlParams;

  switch (email.emailService) {
    case 'email_client':
      host = 'mailto:';
      urlParams = `${target_email}?subject=${subject}&body=${body}`;
      break;
    case 'gmail':
      host = 'https://mail.google.com/mail/?view=cm&fs=1&tf=1&';
      urlParams = `to=${target_email}&su=${subject}&body=${body}`;
      break;
    case 'outlook':
      host = 'https://outlook.com/?path=/mail/action/compose&';
      urlParams = `to=${target_email}&subject=${subject}&body=${body}`;
      break;
    case 'yahoo':
      host = 'https://compose.mail.yahoo.com/?';
      urlParams = `to=${target_email}&subject=${subject}&body=${body}`;
      break;
    default:
      host = 'mailto:';
      urlParams = `${target_email}?subject=${subject}&body=${body}`;
  }
  return `${host}${urlParams}`;
}
