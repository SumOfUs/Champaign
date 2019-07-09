import * as fetchPonyfill from 'fetch-ponyfill';
import wretch from 'wretch';

const { fetch } = fetchPonyfill();
const client = wretch()
  .polyfills({ fetch })
  .accept('application/json');

interface IApiErrors {
  [fieldName: string]: string[];
}
interface IApiResponse {
  errors?: IApiErrors;
}

const api = {
  pages: {
    validateForm(pageId: number | string, payload: any): Promise<IApiResponse> {
      return client
        .url(`/api/pages/${pageId}/actions/validate`)
        .post(payload)
        .error(422, err => JSON.parse(err.text || '{}'))
        .json(json => json);
    },

    createAction(pageId: number | string, payload: any) {
      return client
        .url(`/api/pages/${pageId}/actions`)
        .post(payload)
        .error(422, err => JSON.parse(err.text || '{}'))
        .json(json => json);
    },
  },

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
