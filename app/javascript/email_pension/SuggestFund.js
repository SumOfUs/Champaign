// @flow

import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';

type Props = {
  country: string,
};

type State = {
  showForm: boolean,
  isSubmittingNewPensionFundName: boolean,
  newPensionFundName: string,
};

export default class SuggestFund extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);

    this.state = {
      showForm: false,
      newPensionFundName: '',
      isSubmittingNewPensionFundName: false,
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

  submit = (e: SyntheticEvent) => {
    e.preventDefault();
    this.postSuggestedFund(this.state.newPensionFundName);
  };

  render() {
    return (
      <div className="email-target-action">
        <div className="email__target-suggest-fund">
          <p>
            <a onClick={this.toggle}>Can't find your pension fund?</a>
          </p>
        </div>
        {this.state.showForm && (
          <div className="email-target_box">
            <h3>
              <span>
                We're sorry you couldn't find your pension fund. Send us its
                name and we'll update our records.
              </span>
            </h3>
            <div className="form__group">
              <Input
                name="new_pension_fund"
                label={
                  <FormattedMessage
                    id="email_tool.form.new_pension_fund"
                    defaultMessage="Name of your pension fund"
                  />
                }
                value={this.state.newPensionFundName}
                onChange={this.onChange}
              />
            </div>

            <div className="form__group">
              <Button
                disabled={this.state.isSubmittingNewPensionFundName}
                className="button action-form__submit-button"
                onClick={this.submit}
              >
                Send
              </Button>
            </div>
          </div>
        )}
      </div>
    );
  }
}
