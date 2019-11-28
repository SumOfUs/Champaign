import * as fetchPonyfill from 'fetch-ponyfill';
import wretch from 'wretch';
import pages from './resources/pages';

export interface IApiErrors {
  [fieldName: string]: string[];
}

export interface IApiTracking {
  tracking: object;
}

export interface IApiResponse {
  errors?: IApiErrors;
  tracking?: IApiTracking;
}

const { fetch } = fetchPonyfill();
const w = wretch()
  .polyfills({ fetch })
  .accept('application/json');

export const client = {
  get(url: string) {
    return w.url(url).json(json => json);
  },
  post(url: string, payload: any): Promise<IApiResponse> {
    return w
      .url(url)
      .post(payload)
      .error(422, err => {
        throw JSON.parse(err.text || '{}');
      })
      .json(json => json);
  },
};

const api = {
  pages,
  helpers: {
    formErrorFields(errors: string[]) {
      if (errors && errors.length) {
        return {
          hasError: true,
          errorMessage: errors.join(', '),
        };
      }
    },
  },
};

export default api;
