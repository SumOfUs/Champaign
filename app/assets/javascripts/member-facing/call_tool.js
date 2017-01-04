let ErrorDisplay = require('shared/show_errors');

const CallTool = function() {
  var form = $('form.action-form');
  var countrySelect = form.find('select.action-form__country');
  var phoneInput = form.find('input[type=tel]');
  var submitButton = form.find('button[type=submit]');
  var pageId = window.champaign.personalization.urlParams.id;
  var targets_by_country = window.champaign.personalization.callTool.default.targets_by_country;
  var targets = window.champaign.personalization.callTool.default.targets;
  var selectedTarget = null;

  countrySelect.change(function() { updateTarget(); });
  updateTarget();
  new window.champaign.SweetPlaceholder();
  form.find('select').selectize();

  submitButton.click(function(e) {
    e.preventDefault();

    var data = {
      call: {
        member_phone_number: phoneInput.val(),
        target_index: (selectedTarget === null) ? null : _.findIndex(targets, selectedTarget)
      }
    }

    $.post(`/api/pages/${pageId}/call`, data)
      .then(callCreationSuccess, callCreationFailed);
  });

  function updateTarget() {
    selectNewTarget();
    var targetSpan = $(".action-form__target span");
    if(selectedTarget !== null) {
      targetSpan.text(`${selectedTarget.name}, ${selectedTarget.title}`);
    } else {
      targetSpan.text('');
    }
  }

  function selectNewTarget() {
    if(targets_by_country[countrySelect.val()] !== undefined) {
      selectedTarget = _.sample(targets_by_country[countrySelect.val()]);
    } else {
      selectedTarget = null;
    }
  }

  function callCreationSuccess(data) {
    console.log("Call creation succeeded");
    console.log(data);
    disableButton();
  }

  function callCreationFailed(data, status) {
    console.log("Call creation failed");
    console.log(status);
    console.log(data);
    ErrorDisplay.show({target: form}, data);
  }

  function disableButton() {
    submitButton.text(I18n.t('call_tool.calling'));
    submitButton.addClass('button--disabled');
  }
}

module.exports = CallTool;
