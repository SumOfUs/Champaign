const MAX_RETRIES = 4;
export interface IReCaptchaInstance {
  ready: (cb: () => any) => void;
  execute: (siteKey: string, options: IExecuteOptions) => Promise<string>;
}
interface IExecuteOptions {
  action: string;
}

export const isReady = () => {
  return window.grecaptcha != null && window.grecaptcha.execute != null;
};

export const load = (): Promise<IReCaptchaInstance> => {
  if (isReady()) {
    return Promise.resolve(window.grecaptcha as IReCaptchaInstance);
  }

  const siteKey = window.champaign.configuration.recaptcha3.siteKey;

  const src = `https://www.google.com/recaptcha/api.js?render=${siteKey}`;
  const script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = src;
  script.async = true;
  script.defer = true;
  document.body.appendChild(script);

  return new Promise((resolve, reject) => {
    let retries = 0;
    const id = setTimeout(() => {
      if (window.grecaptcha) {
        resolve(window.grecaptcha);
      } else if (retries >= MAX_RETRIES) {
        reject(new Error('Could not load reCAPTCHA'));
      } else {
        retries = retries + 1;
      }
    }, 400);
  });
};

export const execute = async (options: IExecuteOptions): Promise<string> => {
  const siteKey = window.champaign.configuration.recaptcha3.siteKey;
  const captcha = await load();
  return captcha.execute(siteKey, options);
};

export default {
  load,
  isReady,
  execute,
};
