//@flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import c3 from 'c3';

type OwnProps = {
  data: any
}


class LastWeekChart extends Component {
  props: OwnProps;

  componentDidMount() {
    this.createChart();
  }

  componentDidUpdate() {
    this.createChart();
  }

  createChart() {
    const chart = c3.generate({
      bindto: '#call-tool-analytics-last-week-chart',
      data: {
        json: this.props.data,
        keys: {
          x: 'date',
          value: ['failed', 'unstarted', 'started', 'connected']
        },
        type: 'bar',
      },
      axis: {
        x: {
          type: 'category'
        }
      }
    });
    // Hack to fix positioning of legends
    chart.legend.show();
  }

  render() {
    return <div id="call-tool-analytics-last-week-chart"> Chart </div>;
  }
};

export default LastWeekChart;
