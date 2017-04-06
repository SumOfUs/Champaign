//@flow
import React, { Component } from 'react';
import c3 from 'c3';

type OwnProps = {
  data: any,
  xLabel?: string
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
    const xLabel = this.props.xLabel || '';
    const chart = c3.generate({
      bindto: '#call-tool-analytics-last-week-chart',
      data: {
        json: this.props.data,
        keys: {
          x: 'date',
          value: ['unstarted', 'started', 'connected']
        },
        type: 'bar',
      },
      axis: {
        x: {
          type: 'category',
          label: xLabel
        },
        y: {
          label: 'calls'
        }
      }
    });
    // Hack to fix positioning of legends
    chart.legend.show();
  }

  render() {
    return <div id="call-tool-analytics-last-week-chart"> Chart </div>;
  }
}

export default LastWeekChart;
