//@flow
import React, { Component } from 'react';
import _ from 'lodash';
import classnames from 'classnames';
import { fetchJson } from './Helpers';
import MembersLastWeekChart from '../../components/CallToolAnalytics/MembersLastWeekChart';
import MembersStatusTable from '../../components/CallToolAnalytics/MembersStatusTable';
import TargetsChart from '../../components/CallToolAnalytics/TargetsChart';
import TargetsStatusTable from '../../components/CallToolAnalytics/TargetsStatusTable';


type OwnProps = {
  pageId: string | number
}

type OwnState = {
  data?: {
    last_week: {
      member_calls: any,
      target_calls: any
    }
  },
  filter: string
}

class CallToolViewAnalytics extends Component {
  state: OwnState;
  props: OwnProps;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      dataLoaded: false,
      filter: 'all-time'
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
      console.log('fetch errrrror');
      console.log(response);
      // alert('Oops! Something went wrong, please try reloading the page.');
    });
  }

  updateFilter(filter:string) {
    this.setState({filter});
  }

  render() {
    const lastWeekButtonClasses = classnames(
            {btn: true, 'btn-default': true, active: this.state.filter === 'last-week'}
          ),
          allTimeButtonClasses = classnames(
            {btn: true, 'btn-default': true, active: this.state.filter === 'all-time'}
          );

    if(!this.state.data) {
      return this.renderLoading();
    }

    return(
      <div>
        <h1> Call Tool </h1>
        <div className="nav">
          <div className="btn-group" role="group">
            <button className={lastWeekButtonClasses} type="button" onClick={() => { this.updateFilter('last-week'); }}> Last Week </button>
            <button className={allTimeButtonClasses} type="button" onClick={() => { this.updateFilter('all-time'); }}> All Time </button>
          </div>
        </div>

        <h4> Members stats </h4>

        <div className="row">
          <div className="col1">
            <MembersLastWeekChart data={this.state.data['last_week']['member_calls']['status_totals_by_day']} />
          </div>

          <div className="col2">
            <MembersStatusTable data={this.state.data['last_week']['member_calls']['status_totals']} />
          </div>
        </div>

        <h4> Targets stats </h4>

        <div className="row">
          <div className="col1">
            <TargetsChart data={this.state.data['last_week']['target_calls']['status_totals_by_target']} />
          </div>

          <div className="col2">
            <TargetsStatusTable data={this.state.data['last_week']['target_calls']['status_totals']} />
          </div>
        </div>
      </div>
    );
  }

  renderLoading() {
    return <div> Loading...</div>;
  }
}

export default CallToolViewAnalytics;
