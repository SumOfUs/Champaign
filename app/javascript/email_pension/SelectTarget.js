// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import Input from '../components/SweetInput/SweetInput';
import FormGroup from '../components/Form/FormGroup';

type OwnProps = {
  handler: (target: any) => void,
  endpoint: string,
  error: any,
};

type Target = {
  id: string,
  first_name: string,
  last_name: string,
  title: string,
};

type OwnState = {
  searching: boolean,
  not_found: boolean,
  postcode: string,
  targets: any,
};

class SelectTarget extends Component {
  state: OwnState;
  props: OwnProps;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      searching: false,
      not_found: false,
      postcode: '',
      targets: [],
    };
  }

  getTarget = (postcode: string) => {
    this.setState({ postcode: postcode });

    if (!postcode) return;
    if (postcode.length < 5) return;

    this.setState({ searching: true, not_found: false });
    fetch(`${this.props.endpoint}${postcode}`)
      .then(resp => {
        if (resp.ok) {
          return resp.json();
        }
        throw new Error('not found.');
      })
      .then(json => {
        this.setState({ targets: json, searching: false });
        const data = { postcode, targets: json };
        this.props.handler(data);
      })
      .catch(e => {
        this.setState({ not_found: true, targets: [], searching: false });
        console.log('error', e);
      });
  };

  renderTarget({ id, title, first_name, last_name }: Target) {
    return (
      <p key={id}>
        {title} {first_name} {last_name}
      </p>
    );
  }

  render() {
    let targets;

    if (this.state.not_found) {
      targets = (
        <FormattedMessage
          id="email_tool.select_target.not_found"
          defaultMessage="Sorry, we couldn't find a target with this location."
        />
      );
    } else {
      targets = this.state.targets.length ? (
        this.state.targets.map(target => this.renderTarget(target))
      ) : (
        <FormattedMessage
          id="email_tool.select_target.search_pending"
          defaultMessage="Please enter your postal code above."
        />
      );
    }

    return (
      <div>
        <FormGroup>
          <Input
            name="postcode"
            type="text"
            label={
              <FormattedMessage
                id="email_tool.form.representative.postal_code"
                defaultMessage="Enter your postal code"
              />
            }
            value={this.state.postcode}
            onChange={value => this.getTarget(value)}
            errorMessage={this.props.error}
          />
        </FormGroup>
        <FormGroup>
          <div className="target-panel">
            <h3>
              <FormattedMessage
                id="email_tool.form.representative.selected_targets"
                defaultMessage="Representatives"
              />
            </h3>
            <div className="target-panel-body">
              {this.state.searching ? (
                <FormattedMessage
                  id="email_tool.form.representative.searching"
                  defaultMessage="Searching for your representative"
                />
              ) : (
                targets
              )}
            </div>
          </div>
        </FormGroup>
      </div>
    );
  }
}

export default SelectTarget;
