// @flow
import $ from 'jquery';
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';

type State = {
  showForm: boolean,
  isSubmittingNewPensionFundName: boolean,
  newPensionFundName: string,
  newPensionFundNameError: boolean,
};

export default class SuggestFund extends Component<*, State> {
  constructor() {
    super();
    this.state = {
      showForm: false,
      newPensionFundName: '',
      isSubmittingNewPensionFundName: false,
      newPensionFundNameError: false,
    };
  }

  postSuggestedFund(fund: string) {
    const url = '/api/pension_funds/suggest_fund';

    this.setState({ isSubmittingNewPensionFundName: true });

    $.post(url, {
      'email_target[name]': fund,
    })
      .done(() => {
        this.setState({
          showForm: false,
          isSubmittingNewPensionFundName: false,
          newPensionFundName: '',
          newPensionFundNameError: false,
        });
      })
      .fail(() => {
        console.log('err');
      });
  }

  toggle = () => {
    this.setState(state => ({
      ...state,
      showForm: !state.showForm,
    }));
  };

  onChange = (newPensionFundName: string) => {
    this.setState(state => ({
      ...state,
      newPensionFundName,
    }));
  };

  submit = (e: SyntheticEvent<HTMLElement>) => {
    e.preventDefault();
    if (this.state.newPensionFundName.trim() === '') {
      this.setState({ newPensionFundNameError: true });
    } else {
      this.postSuggestedFund(this.state.newPensionFundName);
    }
  };

  render() {
    const errorMessage = this.state.newPensionFundNameError ? (
      <FormattedMessage
        id="email_tool.form.errors.suggest_fund"
        defaultMessage="Name of pension fund can't be blank"
      />
    ) : (
      ''
    );

    return (
      <div className="email-target-action">
        <div className="email__target-suggest-fund">
          <p>
            <a onClick={this.toggle}>
              <FormattedMessage
                id="email_pension.form.other_pension_fund_text"
                defaultMessage="Can't find your pension fund?"
              />
            </a>
          </p>
        </div>
        {this.state.showForm && (
          <div className="email-target_box">
            <h3>
              <span>
                <FormattedMessage
                  id="email_tool.form.errors.fund_not_found"
                  defaultMessage="We're sorry you couldn't find your pension fund. Send us its
                name and we'll update our records."
                />
              </span>
            </h3>
            <div className="form__group">
              <Input
                name="new_pension_fund"
                label={
                  <FormattedMessage
                    id="email_tool.form.name_of_your_pension_fund"
                    defaultMessage="Name of your pension fund"
                  />
                }
                value={this.state.newPensionFundName}
                onChange={this.onChange}
                errorMessage={errorMessage}
              />
            </div>

            <div className="form__group">
              <Button
                disabled={this.state.isSubmittingNewPensionFundName}
                className="button action-form__submit-button"
                onClick={this.submit}
              >
                <FormattedMessage
                  id="email_tool.form.send_button_text"
                  defaultMessage="Send"
                />
              </Button>
            </div>
          </div>
        )}
      </div>
    );
  }
}
