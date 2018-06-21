// @flow
import uri from 'urijs';

const RegisterMemberRedirector = {
  attemptRedirect(followUpUrl: string, member: any) {
    if (typeof member !== 'object') {
      member = window.champaign.personalization.member;
    }

    if (shouldMemberRegister()) {
      redirectToRegistration();
      return true;
    } else {
      return false;
    }

    function shouldMemberRegister() {
      return !member.registered;
    }

    function redirectToRegistration() {
      redirectTo(registrationUrl(followUpUrl, member.email));
    }

    function registrationUrl(url, email) {
      return uri('/member_authentication/new')
        .query({ follow_up_url: url, email: email })
        .toString();
    }
  },
};

const AfterDonationRedirector = {
  attemptRedirect(followUpUrl: string, donationFormData: any) {
    if (
      !(
        donationFormData.storeInVault &&
        RegisterMemberRedirector.attemptRedirect(
          followUpUrl,
          donationFormData.member
        )
      )
    ) {
      redirectTo(followUpUrl);
    }

    return true;
  },
};

function redirectTo(url) {
  window.location.href = url;
}

export default {
  RegisterMemberRedirector,
  AfterDonationRedirector,
};
