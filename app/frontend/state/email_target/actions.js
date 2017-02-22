const initialState = {
  emailBody: '',
  emailSubject: '',
  name: '',
  email: '',
  fund: 'Fund A',
  to: 'Bob Fisher',
  page: ''
};


const funds = {
  'FUND A': {
    name: "Bob Fisher",
    email: 'bob@example.com',
  },
  'FUND B': {
    name: "Michael Dank",
    email: 'michael@example.com',
  }
};


export const reducer = (state = initialState, action) => {
  switch (action.type) {
    case 'email_target:change_body':
      return { ...state, emailBody: action.emailBody };
    case 'email_target:change_subject':
      return { ...state, emailSubject: action.emailSubject };
    case 'email_target:change_email':
      return { ...state, email: action.email };
    case 'email_target:change_name':
      return { ...state, name: action.name };
    case 'email_target:change_fund':
      const fund = action.fund;
      const contact = {fundEmail: fund.email, fundContact: fund.contact_name, fund: fund.fund_name };
      console.log(contact, action);
      return { ...state, ...contact};
    case 'email_target:initialize':
      return { ...state, ...action.payload };
    default:
      return state;
  };
};

export const changeBody = (emailBody) => {
  return { type: 'email_target:change_body', emailBody };
};

export const changeSubject = (emailSubject) => {
  return { type: 'email_target:change_subject', emailSubject };
};

export const changeName = (name) => {
  return { type: 'email_target:change_name', name};
};

export const changeEmail = (email) => {
  return { type: 'email_target:change_email', email };
};

export const changeFund = (fund) => {
  return { type: 'email_target:change_fund', fund };
};
