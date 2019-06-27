import $ from 'jquery';

const api = {
  pages: {
    validateForm(pageId: number | string, payload: any) {
      return $.post(`/api/pages/${pageId}/validate`, payload);
    },
    createAction(pageId: number | string, payload: any) {
      return $.post(`/api/pages/${pageId}/actions`, payload);
    },
  },
};

export default api;
