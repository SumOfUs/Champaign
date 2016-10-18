var helpers = {
  currentStepOf: function(stepCount) {
    var current = -1;
    for (var ii = 1; ii <= stepCount; ii++) {
      if (!$('.fundraiser-bar__step-panel[data-step="'+ii+'"]').hasClass('hidden-closed')) {
        if (current !== -1) { return -1; } // only one should be visible
        current = ii;
      }
    };
    return current;
  },

  last: function(arr) {
    return arr[arr.length-1];
  },

  lastRequestBodyPairs: function(suite){
    request = this.last(suite.server.requests);
    return decodeURI(request.requestBody).split('&');
  },

  allTexts: function(selector) {
    return $(selector).map(function(ii, el){ return $(el).text() }).toArray();
  },

  btNonce: 'noceynonceynonce',
  btData: { nonce: 'noceynonceynonce', deviceData: JSON.stringify({foo: 'bar'})},
  btClientToken: "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI5MzZiNzEzMDY1NzgzYTZkMDI5ZTE0MjBlMWY3YTVlMTI2ZGZlYjNkYjBkNzU4ZjFhMDgzMTE3ZGQyOTYxNjM0fGNyZWF0ZWRfYXQ9MjAxNS0xMS0yM1QxOTo1MTowMS40ODQxOTQ0NTMrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTZuZ2J3aHl0Ymhyejl6MnJcdTAwMjZwdWJsaWNfa2V5PXY5ZnBjMmd6cWZ4eDQ1bnEiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvNm5nYndoeXRiaHJ6OXoyci9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbImN2diJdLCJlbnZpcm9ubWVudCI6InNhbmRib3giLCJjbGllbnRBcGlVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvNm5nYndoeXRiaHJ6OXoyci9jbGllbnRfYXBpIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhdXRoVXJsIjoiaHR0cHM6Ly9hdXRoLnZlbm1vLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhbmFseXRpY3MiOnsidXJsIjoiaHR0cHM6Ly9jbGllbnQtYW5hbHl0aWNzLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6ZmFsc2UsInBheXBhbEVuYWJsZWQiOnRydWUsInBheXBhbCI6eyJkaXNwbGF5TmFtZSI6IlN1bU9mVXMiLCJjbGllbnRJZCI6bnVsbCwicHJpdmFjeVVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS9wcCIsInVzZXJBZ3JlZW1lbnRVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vdG9zIiwiYmFzZVVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9jaGVja291dC5wYXlwYWwuY29tIiwiZGlyZWN0QmFzZVVybCI6bnVsbCwiYWxsb3dIdHRwIjp0cnVlLCJlbnZpcm9ubWVudE5vTmV0d29yayI6dHJ1ZSwiZW52aXJvbm1lbnQiOiJvZmZsaW5lIiwidW52ZXR0ZWRNZXJjaGFudCI6ZmFsc2UsImJyYWludHJlZUNsaWVudElkIjoibWFzdGVyY2xpZW50MyIsImJpbGxpbmdBZ3JlZW1lbnRzRW5hYmxlZCI6bnVsbCwibWVyY2hhbnRBY2NvdW50SWQiOiJzdW1vZnVzIiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6ZmFsc2UsIm1lcmNoYW50SWQiOiI2bmdid2h5dGJocno5ejJyIiwidmVubW8iOiJvZmYifQ=="
};
