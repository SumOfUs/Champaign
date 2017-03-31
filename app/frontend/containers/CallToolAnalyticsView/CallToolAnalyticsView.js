//@flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import { fetchJson } from './Helpers';
import MembersLastWeekChart from '../../components/CallToolAnalytics/MembersLastWeekChart';
import MembersLastWeekTable from '../../components/CallToolAnalytics/MembersLastWeekTable';


type OwnProps = {
  pageId: string | number
}

type OwnState = {
  data?: {
    last_week: {
      member_calls: any,
    }
  }
}

class CallToolViewAnalytics extends Component {
  state: OwnState;
  props: OwnProps;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      dataLoaded: false
    };
  }

  componentDidMount() {
    this.fetchData();
  }

  fetchData() {
    const url = `/api/pages/${this.props.pageId}/analytics/call_tool`;
    fetchJson(url).then((json) => {
      this.setState({data: json['data']});
    }).catch((response) => {
      alert('Oops! Something went wrong, please try reloading the page.');
    });
  }

  render() {
    if(!this.state.data) {
      return this.renderLoading();
    }

    return(
      <div>
        <h1> Call Tool </h1>
        <div className="nav">
          <div className="btn-group" role="group">
            <button className="btn btn-default active" type="button"> Last Week </button>
            <button className="btn btn-default active" type="button"> All Time </button>
          </div>
        </div>

        <h3> Members stats </h3>

        <div>
          <div className="col1">
            <MembersLastWeekChart data={this.state.data['last_week']['member_calls']['status_totals_by_day']} />
          </div>

          <div className="col2">
            <MembersLastWeekTable data={this.state.data['last_week']['member_calls']['status_totals']} />
          </div>
        </div>

        <h3> Targets stats </h3>

        <div>
        </div>
      </div>
    );
  }

  renderLoading() {
    return <div> Loading...</div>;
  }
}

export default CallToolViewAnalytics;
