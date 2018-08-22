import React, { Component } from 'react';
import ReactDOM from 'react-dom';

const NoEmailsFound = () => <p>No emails were found</p>;

const Email = props => {
  const body = () => ({ __html: props.Body });

  return (
    <div className="panel panel-default">
      <div className="panel-heading">
        <h3 className="panel-title">{props.Subject}</h3>
        <h3 className="panel-title">{props.CreatedAt}</h3>
        <h3 className="panel-title">
          <strong>To: </strong>
          {props.ToEmails.join(', ')}
        </h3>
      </div>
      <div className="panel-body">
        <div dangerouslySetInnerHTML={body()} />
      </div>
    </div>
  );
};

class Emails extends Component {
  state = {
    emails: [],
    next: null,
    loading: true,
  };

  fetchEmails() {
    let uri = `/api/email_target_emails?slug=${this.props.page}`;

    if (this.state.next) {
      uri += `&next=${this.state.next}`;
    }

    fetch(uri)
      .then(resp => resp.json())
      .then(json => {
        this.setState((pre, props) => ({
          emails: [...pre.emails, ...json.items],
          next: json.next,
          loading: false,
        }));
      });
  }

  componentDidMount() {
    this.fetchEmails();
  }

  render() {
    const emails = this.state.emails.length ? (
      this.state.emails.map(email => <Email key={email.MailingId} {...email} />)
    ) : (
      <NoEmailsFound />
    );

    const pagination = this.state.next ? (
      <button className="btn btn-default" onClick={this.fetchEmails.bind(this)}>
        Load more...
      </button>
    ) : null;

    return (
      <div>
        <div>{this.state.loading ? <p>Fetching...</p> : emails}</div>
        <div>{pagination}</div>
      </div>
    );
  }
}

const page = window.location.pathname.split('/')[2];

ReactDOM.render(
  <Emails page={page} />,
  document.getElementById('email-target-view-root')
);
