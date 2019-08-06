$(document).ready(function(e) {
  $(document).on('click', '.pf-export-btn', function(e) {
    var country_code = $('#pf-country-code').val();
    if (country_code != '') {
      location.href = '/pension_funds/export?country_code=' + country_code;
    } else {
      alert('Select a country to continue ...');
      return false;
    }
  });
});
