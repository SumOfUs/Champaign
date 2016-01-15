"use strict";

class AnalyticsDashboard {
  constructor () {
    this.barPadding   = 1;
    this.bottomMargin = 100;
    this.margins      = { bottom: 30 };
    this.xAxis        = true;
    this.labels       = true;
  }

  render () {
    this.updateSVG();
    this.setYScale(this.data);
    this.draw();

    if(this.labels) {
      this.drawLabels();
    }

    if(this.xAxis) {
      this.drawAxis();
    }
  }

  updateSVG () {
    this.svg
      .attr("width", this.width)
      .attr("height", this.height + this.margins.bottom);
  }

  updateData () {
    this.getData( () => {
      this.setYScale(this.data);
      this.updateAll();
    });
  }

  updateAll () {
    this.svg.selectAll(".bar")
      .data(this.data)
      .transition()
      .duration(750)
      .attr("height", (d) => {
        return this.scale(d.value);
      })
      .attr("y", (d) => {
        return this.height - this.scale(d.value);
      });

    this.drawLabels();
    this.svg.selectAll(".label")
      .data(this.data)
      .transition()
      .duration(1000)
      .text((d) => {
        return d.value;
      })
      .attr("y",    this.setYForLabel.bind(this)    )
      .attr("fill", this.setFillForLabel.bind(this) );
  }

  setYForLabel (d) {
    let scaled = this.scale(d.value);
    let y = this.height - scaled + 15;
    if(scaled < 20 ) {
      y -= 20;
    }

    return y;
  }

  setFillForLabel (d) {
    return (this.scale(d.value) < 20) ? '#333' : '#fff';
  }

  draw () {
    this.svg.selectAll(".bar")
      .data(this.data)
      .enter()
      .append("rect")
      .attr("width", this.width / this.data.length - this.barPadding)
      .attr("fill", this.fill)
      .attr("class", 'bar')
      .attr("height", (d) => {
        return this.scale(d.value);
      })
      .attr("y", (d) => {
        return this.height - this.scale(d.value);
      })
      .attr("x", (d, i) => {
        return i * (this.width / this.data.length);
      });
  }

  drawLabels () {
    this.svg.selectAll("text")
      .data(this.data)
      .enter()
      .append("text")
      .text((d) => {
        return d.value;
      })
      .attr("x", (d, i) => {
        return i * (this.width / this.data.length) + (this.width / this.data.length - this.barPadding) / 2;
      })
      .attr("y", this.setYForLabel.bind(this) )
      .attr("class", "label")
      .attr("text-anchor", "middle")
      .attr("font-family", "sans-serif")
      .attr("font-size", "11px")
      .attr("fill", this.setFillForLabel.bind(this) );
  }

  drawAxis () {
    var xScale = d3.scale.ordinal()
                   .domain(this.data.map( (d, i) => {
                     return moment(d.date).format(this.axisDateFormat);
                   }))
                   .rangeBands([0, this.width]);


    var xAxis = d3.svg.axis()
                  .scale(xScale)
                  .orient('bottom')


    this.svg.append("g")
        .attr("class", "x axis")
        .attr("transform", `translate(0, ${(this.height)})`)
        .call(xAxis);
  }

  setYScale (dataset) {
    this.scale = d3.scale.linear()
                   .domain([0, d3.max( dataset, (d) => {
                     return d.value;
                   })])
                   .range( [0, this.height]);

  }
}

class Dashboard {
  constructor (id) {
    this.id = id;
  }

  getData (cb) {
    d3.json(`/api/pages/${this.id}/analytics.json`, (json)  => {
      if(cb) {
        cb(json);
      }
    });
  }

}

var createMiniChart = (className, data) => {
  var svg = d3.select(`#analytics-dashboard .${className} .chart`)
  var chart = new AnalyticsDashboard();
  chart.width = 360;
  chart.height = 70;
  chart.fill = 'rgba(51,51,51,0.3)';
  chart.data = data;
  chart.xAxis = false;
  chart.labels = false;
  chart.svg = svg;
  return chart;
}

module.exports = {
  makeDashboard (pageId) {
    var d = new Dashboard(pageId);
    var shortChartSVG = d3.select("#analytics-dashboard .short-view .chart")

    d.getData( (resp) => {
      var totals = resp.totals
      $('.total-actions-all').html(totals.all_total);
      $('.total-actions-new').html(totals.new_total);

      let shortChart = new AnalyticsDashboard();
      shortChart.width = 650;
      shortChart.height = 280;
      shortChart.data = resp.hours;
      shortChart.fill = 'rgba(51,51,51,1)';
      shortChart.svg = shortChartSVG;
      shortChart.axisDateFormat = 'HH a';
      shortChart.render();


      createMiniChart('mini-total', resp.days_total.reverse())
        .render();

      createMiniChart('mini-new', resp.days_new.reverse())
        .render();
    });
  }
}

