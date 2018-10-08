const initialState = {
  name: '',
  email: '',
  postcode: '',
  isSubmitting: false,
  emailSubject: '',
  fundContact: '',
  fundEmail: '',
  fundContact: '',
  fundId: '',
  fund: '',
  country: '',
};

export const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'email_target:change_submitting':
      return { ...state, isSubmitting: action.submitting };
    case 'email_target:change_country':
      return { ...state, country: action.country };
    case 'email_target:change_body':
      return { ...state, emailBody: action.emailBody };
    case 'email_target:change_subject':
      return { ...state, emailSubject: action.emailSubject };
    case 'email_target:change_email':
      return { ...state, email: action.email };
    case 'email_target:change_name':
      return { ...state, name: action.name };
    case 'email_target:change_pension_funds':
      return { ...state, pensionFunds: action.funds };
    case 'email_target:change_fund':
      const fund = action.fund;

      if (!fund) {
        return {
          ...state,
          fundEmail: undefined,
          fundContact: undefined,
          fundId: undefined,
          fund: undefined,
        };
      }

      return {
        ...state,
        fundEmail: fund.email,
        fundContact: fund.name,
        fundId: fund._id,
        fund: fund.fund,
      };
    case 'email_target:initialize':
      const { email, name, emailSubject, country, fundId } = action.payload;
      return { ...state, email, name, emailSubject, country, fundId };
    default:
      return state;
  }
};

export const changeSubmitting = submitting => {
  return { type: 'email_target:change_submitting', submitting };
};

export const changeBody = emailBody => {
  return { type: 'email_target:change_body', emailBody };
};

export const changeCountry = country => {
  return { type: 'email_target:change_country', country };
};

export const changeSubject = emailSubject => {
  return { type: 'email_target:change_subject', emailSubject };
};

export const changeName = name => {
  return { type: 'email_target:change_name', name };
};

export const changeEmail = email => {
  return { type: 'email_target:change_email', email };
};

export const changeFund = fund => {
  return { type: 'email_target:change_fund', fund };
};

export const changePensionFunds = funds => {
  return { type: 'email_target:change_pension_funds', funds };
};

export const findMP = postcode => {
  return { type: 'email_target:find_mp', postcode };
};
