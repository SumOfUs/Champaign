//@flow
import React, { Component } from 'react';
import c3 from 'c3';

type OwnProps = {
  data: any,
};

class TargetsChart extends Component<OwnProps> {
  componentDidMount() {
    this.createChart();
  }

  componentDidUpdate() {
    this.createChart();
  }

  createChart() {
    const chart = c3.generate({
      bindto: '#call-tool-analytics-targets-chart',
      data: {
        type: 'bar',
        json: this.props.data,
        keys: {
          x: 'target_name',
          value: ['completed', 'busy', 'no-answer', 'failed'],
        },
        groups: [['completed', 'busy', 'no-answer', 'failed']],
      },
      axis: {
        rotated: 'true',
        x: {
          type: 'category',
        },
        y: {
          label: 'calls',
        },
      },
    });
    // Hack to fix positioning of legends
    chart.legend.show();
  }

  render() {
    return <div id="call-tool-analytics-targets-chart"> Chart </div>;
  }
}

export default TargetsChart;
