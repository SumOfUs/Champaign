//
import React, { Component } from 'react';
import classnames from 'classnames';
import { fetchJson } from './helper';
import MembersChart from '../../components/CallToolAnalytics/MembersChart';
import MembersStatusTable from '../../components/CallToolAnalytics/MembersStatusTable';
import TargetsChart from '../../components/CallToolAnalytics/TargetsChart';
import TargetsStatusTable from '../../components/CallToolAnalytics/TargetsStatusTable';

class CallToolViewAnalytics extends Component {
  constructor(props) {
    super(props);

    this.state = {
      dataLoaded: false,
      filter: 'all_time',
    };
  }

  componentDidMount() {
    this.fetchData();
  }

  fetchData() {
    const url = `/api/pages/${this.props.pageId}/analytics/call_tool`;
    fetchJson(url)
      .then(json => {
        this.setState({ data: json['data'] });
      })
      .catch(response => {
        alert('Oops! Something went wrong, please try reloading the page.');
      });
  }

  updateFilter(filter) {
    this.setState({ filter });
  }

  render() {
    if (!this.state.data) {
      return this.renderLoading();
    }

    const lastWeekButtonClasses = classnames({
        btn: true,
        'btn-default': true,
        active: this.state.filter === 'last_week',
      }),
      allTimeButtonClasses = classnames({
        btn: true,
        'btn-default': true,
        active: this.state.filter === 'all_time',
      });

    return (
      <div>
        <h1> Call Tool </h1>
        <div className="nav">
          <div className="btn-group" role="group">
            <button
              className={lastWeekButtonClasses}
              type="button"
              onClick={() => {
                this.updateFilter('last_week');
              }}
            >
              {' '}
              Last Week{' '}
            </button>
            <button
              className={allTimeButtonClasses}
              type="button"
              onClick={() => {
                this.updateFilter('all_time');
              }}
            >
              {' '}
              All Time{' '}
            </button>
          </div>
        </div>

        <h4> Members stats </h4>

        <div className="row">
          <div className="col1">
            {this.state.filter === 'last_week' && (
              <MembersChart
                data={
                  this.state.data &&
                  this.state.data['last_week']['member_calls'][
                    'status_totals_by_day'
                  ]
                }
              />
            )}
            {this.state.filter === 'all_time' && (
              <MembersChart
                data={
                  this.state.data &&
                  this.state.data['all_time']['member_calls'][
                    'status_totals_by_week'
                  ]
                }
                xLabel="week"
              />
            )}
          </div>

          <div className="col2">
            <MembersStatusTable
              data={
                this.state.data &&
                this.state.data[this.state.filter]['member_calls'][
                  'status_totals'
                ]
              }
            />
          </div>
        </div>

        <h4> Targets stats </h4>

        <div className="row">
          <div className="col1">
            <TargetsChart
              data={
                this.state.data &&
                this.state.data[this.state.filter]['target_calls'][
                  'status_totals_by_target'
                ]
              }
            />
          </div>

          <div className="col2">
            <TargetsStatusTable
              data={
                this.state.data &&
                this.state.data[this.state.filter]['target_calls'][
                  'status_totals'
                ]
              }
            />
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
