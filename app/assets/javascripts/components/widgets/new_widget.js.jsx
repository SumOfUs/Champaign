var NewWidget = React.createClass({

  propTypes: {
    campaign_page_id: React.PropTypes.number.isRequired
  },

  getInitialState() {
    return { widgetType: "none" };
  },

  showForm() {
    var widgetType = React.findDOMNode(this.refs.picker).value
    this.setState( {widgetType: widgetType} );
  },

  picker() {
    return (
      <div className="new-widget-picker">
        <select ref='picker' defaultValue="none" onChange={this.showForm}>
          <option value="none">Select a widget to add</option>
          <option value="TextBodyWidget">Text Body Widget</option>
          <option value="PetitionWidget">Petition Widget</option>
          <option value="ImageWidget">Image Widget</option>
          <option value="ThermometerWidget">Thermometer Widget</option>
          <option value="RawHtmlWidget">Raw Html Widget</option>
        </select>
      </div>
    )
  },

  form() {
    switch (this.state.widgetType) {
      case "TextBodyWidget":
        return (<TextBodyWidgetForm campaign_page_id={this.props.campaign_page_id}></TextBodyWidgetForm>)
      case "RawHtmlWidget":
        return (<RawHtmlWidgetForm campaign_page_id={this.props.campaign_page_id}></RawHtmlWidgetForm>)
      default:
        return "Pick a widget type to create a new widget!"
    }
  },

  render(){
    return (
      <div className='widget'>
        { this.picker() }
        { this.form() }
      </div>
    )
  }
})
