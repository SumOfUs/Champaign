import { client, IApiResponse } from '../index';

export default {
  validateForm(pageId: number | string, payload: any): Promise<IApiResponse> {
    return client.post(`/api/pages/${pageId}/actions/validate`, payload);
  },

  createAction(pageId: number | string, payload: any): Promise<IApiResponse> {
    return client.post(`/api/pages/${pageId}/actions`, payload);
  },
};
