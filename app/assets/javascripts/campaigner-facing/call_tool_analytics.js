const fetchJson = (url) => {
  const options = { credentials: 'include', redirect: 'error' };
  return fetch(url, options).then((response) => {
    if(response.status === 200) {
      return response.json();
    } else {
      return Promise.reject(response);
    }
  });
}

const buildChart = (containerId, jsonData) => {
  var chart = c3.generate({
    bindto: containerId,
    data: {
      json: jsonData,
      keys: {
        x: 'date',
        value: ['failed', 'unstarted', 'started', 'connected']
      },
      type: 'bar',
    },
    axis: {
      x: {
        type: 'category'
      }
    }
  });
  // Hack to fix positioning of legends
  chart.legend.show();
}

const initChart = (containerId, pageId) => {
  const url = `/api/pages/${pageId}/analytics/call_tool`;
  fetchJson(url).then((json) => {
    buildChart(containerId, json['last_week']['member_calls']['status_totals_by_day']);
  }).catch((response) => {
    alert('Oops! Something went wrong, please try reloading the page.');
  });
}

module.exports = {
  initChart
};
