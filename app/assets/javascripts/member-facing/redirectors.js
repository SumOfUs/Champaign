const RegisterMemberRedirector = {
  attemptRedirect:  function(followUpUrl, member) {

    if(typeof(member) !== 'object') {
      member = window.champaign.personalization.member;
    }

    if ( shouldMemberRegister() ) {
      redirectToRegistration();
      return true;
    } else {
      return false;
    }

    function shouldMemberRegister() {
      return !member.registered;
    }

    function redirectToRegistration() {
      var url = `/member_authentication/new?follow_up_url=${encodeURIComponent(followUpUrl)}&email=${encodeURIComponent(member.email)}`;
      window.location.href = url;
    }
  }
};

const AfterDonationRedirector = {
  attemptRedirect: function (followUpUrl, donationFormData) {
    if(!(donationFormData.storeInVault && RegisterMemberRedirector.attemptRedirect(followUpUrl, donationFormData.member))) {
      redirectTo(followUpUrl);
    }

    return true;

    function redirectTo(url) {
      window.location.href = url;
    }
  }
};

module.exports = {
  RegisterMemberRedirector: RegisterMemberRedirector,
  AfterDonationRedirector:  AfterDonationRedirector
};
