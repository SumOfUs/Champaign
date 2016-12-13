import uri from 'urijs';

const RegisterMemberRedirector = {
  attemptRedirect(followUpUrl, member) {
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
      redirectTo(
        registrationUrl(followUpUrl, member.email)
      );
    }

    function registrationUrl(url, email) {
      return uri('/member_authentication/new')
        .query(`follow_up_url=${uri.encode(url)}`)
        .addQuery(`email=${uri.encode(email)}`)
        .toString();
    }
  }
};

const AfterDonationRedirector = {
  attemptRedirect(followUpUrl, donationFormData) {
    if(!(donationFormData.storeInVault && RegisterMemberRedirector.attemptRedirect(followUpUrl, donationFormData.member))) {
      redirectTo(followUpUrl);
    }

    return true;
  }
};

function redirectTo(url) {
  window.location.href = url;
}

module.exports = {
  RegisterMemberRedirector: RegisterMemberRedirector,
  AfterDonationRedirector:  AfterDonationRedirector
};
