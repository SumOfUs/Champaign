import React, { Component } from 'react';
import ReactDOM from 'react-dom';

const NoEmailsFound = () => <p>No emails were found</p>;

const Email = props => {
  const body = () => ({ __html: props.Body });
  console.log(props.Recipients);
  return (
    <div className="panel panel-default">
      <div className="panel-heading">
        <h3 className="panel-title">{props.Subject}</h3>
        <h3 className="panel-title">{props.CreatedAt}</h3>
        <h3 className="panel-title">
          <strong>To: </strong>
          {props.Recipients.map(({ email }) => email).join(', ')}
        </h3>
      </div>
      <div className="panel-body">
        <div dangerouslySetInnerHTML={body()} />
      </div>
    </div>
  );
};

class DownloadForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      email: '',
      submitting: false,
      submitted: false,
      error: false,
    };
  }

  handleSubmit(e) {
    e.preventDefault();

    const re = /\S+@\S+\.\S+/;
    if (!re.test(this.state.email)) return;

    this.setState({ submitting: true });

    const opts = {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        slug: this.props.page,
        email: this.state.email,
      }),
    };

    fetch('/api/email_target_emails/download', opts)
      .then(resp => resp.json())
      .then(json => {
        this.setState({ submitting: false, email: '', submitted: true });
        window.setTimeout(() => this.setState({ submitted: false }), 10000);
      })
      .catch(() => {
        this.setState({ submitting: false, error: true });
        window.setTimeout(() => this.setState({ error: false }), 10000);
      });
  }

  handleChange(e) {
    this.setState({ email: e.target.value });
  }

  render() {
    return (
      <div>
        <form className="form-inline" onSubmit={this.handleSubmit.bind(this)}>
          <div className="input-group">
            <input
              onChange={this.handleChange.bind(this)}
              className="form-control"
              placeholder="Email Address"
            />
            <span className="input-group-btn">
              <button
                type="submit"
                disabled={this.state.submitting}
                className="btn btn-default"
              >
                {this.state.submitting ? 'Processing' : 'Export as CSV'}
              </button>
            </span>
          </div>
        </form>
        {this.state.submitted ? (
          <span className="label label-success">Now go check your email!</span>
        ) : (
          ''
        )}
        {this.state.error ? (
          <span className="label label-danger">
            Whoops! Sorry, something went wrong.
          </span>
        ) : (
          ''
        )}
      </div>
    );
  }
}

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
        <div className="panel panel-default">
          <div className="panel-body">
            <DownloadForm page={this.props.page} />
          </div>
        </div>
        <div>{this.state.loading ? <p>Fetching...</p> : emails}</div>
        <div>{pagination}</div>
      </div>
    );
  }
}

const page = window.location.pathname.split('/')[2];

if (document.getElementById('email-target-view-root')) {
  ReactDOM.render(
    <Emails page={page} />,
    document.getElementById('email-target-view-root')
  );
}
