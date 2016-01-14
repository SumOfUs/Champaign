"use strict";

class AnalyticsDashboard {
  constructor (pageId) {
    this.width = 550;
    this.height = 300;
    this.barPadding = 1;
    this.pageId = pageId;
    this.bottomMargin = 100;
    this.margins = { bottom: 30 }
  }

  render () {
    if(!this.svg) {
      this.createSVG();
    }

    this.getData( () => {
      this.setYScale(this.dataset);
      this.draw();
      this.drawLabels();
      this.drawAxis()
    });
  }

  createSVG () {
    var box = d3.select("#analytics-dashboard .charts")
      .append("div")
      .attr("class", "analytics-chart")

    this.svg = box
      .append("svg")
      .attr("width", this.width)
      .attr("height", this.height + this.margins.bottom);
  }

  getData (cb) {
    d3.json(`/api/pages/${this.pageId}/analytics`, (json)  => {
      this.dataset = json.data.hours.reverse();
      this.totals = json.data.totals;
      $('.total-actions-all').html(this.totals.all);
      $('.total-actions-new').html(this.totals['new']);
      cb()
    });
  }

  updateData () {
    this.getData( () => {
      this.setYScale(this.dataset);
      this.updateAll();
    });
  }

  updateAll () {
    this.svg.selectAll(".bar")
      .data(this.dataset)
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
      .data(this.dataset)
      .transition()
      .duration(1750)
      .text((d) => {
        return d.value;
      })
      .attr("y",  this.setYForLabel.bind(this) )
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
      .data(this.dataset)
      .enter()
      .append("rect")
      .attr("width", this.width / this.dataset.length - this.barPadding)
      .attr("fill", "#333333")
      .attr("class", 'bar')
      .attr("height", (d) => {
        return this.scale(d.value);
      })
      .attr("y", (d) => {
        return this.height - this.scale(d.value);
      })
      .attr("x", (d, i) => {
        return i * (this.width / this.dataset.length);
      });
  }

  drawLabels () {
    this.svg.selectAll("text")
      .data(this.dataset)
      .enter()
      .append("text")
      .text((d) => {
        return d.value;
      })
      .attr("x", (d, i) => {
        return i * (this.width / this.dataset.length) + (this.width / this.dataset.length - this.barPadding) / 2;
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
                   .domain(this.dataset.map( (d) => { return moment(d.date).format('HH a')}))
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
                   .domain([0, d3.max( dataset, (d) => { return d.value })])
                   .range( [0, this.height]);

  }
}


module.exports = AnalyticsDashboard;
