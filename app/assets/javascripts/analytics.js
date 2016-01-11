"use strict";

let options = {
  responsive: true,
  scaleShowVerticalLines: false,

  scales: {
    offsetGridLines: true,
    xAxes: [{
      stacked: true,
      display: false,

      gridLines: {
        display: false,
        color: 'red'
		  },

      ticks: {
        beginAtZero: true
      }
    }],

    yAxes: [{
      stacked: true,
      ticks: {
        suggestedMax: 3
      }
    }]
  }
}



class MainChart {
  constructor (id) {
    this.ctx = document.getElementById(id).
      getContext("2d");
  }

  renderLine (data) {
    this.chart.Line(data)
  }

  renderBar (data) {
    this.chart = new Chart(this.ctx, {
      type: 'bar',
      data: data,
      options: options
    });
  }
}

let data = {
    labels: ["jan", "", 'march', 'april', 'may', 'jun'],

    datasets: [
      {
        backgroundColor: "rgba(103,139,177,1)",
        borderColor: 'white',
        data: [10,16,9,4,9,12   ],
        type: 'bar'
      },
      {
        data: [5, 15, 3, 2, 5, 6],
        backgroundColor: "rgba(136,171,200,1)",
        borderColor: 'white',
        type: 'bar'
      }
    ]
}

$( () => {
  let foo = new MainChart('chart');
  foo.renderBar(data, options);
})

