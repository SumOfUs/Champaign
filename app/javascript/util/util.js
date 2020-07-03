import { camelCase, mapKeys, mapValues, forEach } from 'lodash';

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

export function getToEmailBasedOn(emailItem, emailService) {
  if (emailService == 'yahoo') {
    return emailItem.email;
  } else {
    return `${emailItem.name} <${emailItem.email}>`;
  }
}

export function buildToEmailForCompose(emailList, emailService) {
  // emailList = [{name: 'ABC', email: 'abs@xyz.com'}];
  let toEmailAddresses;
  forEach(emailList, emailItem => {
    const currentEmail = getToEmailBasedOn(emailItem, emailService);
    toEmailAddresses = toEmailAddresses
      ? `${toEmailAddresses}, ${currentEmail}`
      : currentEmail;
  });
  return toEmailAddresses;
}

export function composeEmailLink(email) {
  const sanitizedToEmails = buildToEmailForCompose(
    email.toEmails,
    email.emailService
  );
  const to_email = encodeURIComponent(sanitizedToEmails);
  const subject = encodeURIComponent(email.subject);
  const body = encodeURIComponent(email.body);
  let host, urlParams;

  switch (email.emailService) {
    case 'email_client':
      host = 'mailto:';
      urlParams = `${to_email}?subject=${subject}&body=${body}`;
      break;
    case 'gmail':
      host = 'https://mail.google.com/mail/?view=cm&fs=1&tf=1&';
      urlParams = `to=${to_email}&su=${subject}&body=${body}`;
      break;
    case 'outlook':
      host = 'https://outlook.live.com/?path=/mail/action/compose&';
      urlParams = `to=${to_email}&subject=${subject}&body=${body}`;
      break;
    case 'yahoo':
      host = 'https://compose.mail.yahoo.com/?';
      urlParams = `to=${to_email}&subject=${subject}&body=${body}`;
      break;
    default:
      host = 'mailto:';
      urlParams = `${to_email}?subject=${subject}&body=${body}`;
  }
  return `${host}${urlParams}`;
}
