var WidgetsBox = React.createClass({
  getInitialState() {
    return { data: [] };
  },

  componentDidMount() {
    $.getJSON("/campaign_pages/" + this.props.campaign_page_id + "/widgets.json", function(data){
      this.setState({data: data});
    }.bind(this))
  },

  handleWidgetSubmit(data) {
    $.ajax({
      type: "PUT",
      url: "/campaign_pages/" + this.props.campaign_page_id + "/widgets/" + data.widget.id,
      data: data
    }).done(function( data ) {
      this.setState({data: data})
    }.bind(this));
  },

  render() {
    return (
      <div className='widgets'>
        <Widgets onWidgetSubmit={this.handleWidgetSubmit} widgets={this.state.data} campaign_page_id={ this.props.campaign_page_id } />
      </div>
    )
  }
})

var Widgets = React.createClass({

  propTypes: {
    widgets:          React.PropTypes.array.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired
  },

  render(){
    var widgets = this.props.widgets.map(widget => {
      switch (widget.type) {
        case "TextBodyWidget":
          return (<TextBodyWidget {...widget} onWidgetSubmit={this.props.onWidgetSubmit}></TextBodyWidget>)
        case "RawHtmlWidget":
          return (<RawHtmlWidget {...widget} onWidgetSubmit={this.props.onWidgetSubmit}></RawHtmlWidget>)
        default:
          break;
      }
    })

    return (
      <div className="widgets">
        { widgets }
      </div>
    )
  }
})
