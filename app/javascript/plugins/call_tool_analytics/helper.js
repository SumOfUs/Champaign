export const fetchJson = url => {
  const options = { credentials: 'include', redirect: 'error' };
  return fetch(url, options).then(response => {
    if (response.status === 200) {
      return response.json();
    } else {
      return Promise.reject(response);
    }
  });
};
