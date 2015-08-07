var TextBodyWidgetForm = require('components/widgets/text_body_widget_form')
var RawHtmlWidgetForm  = require('components/widgets/raw_html_widget_form')
var mixins             = require('flux/mixins')


var NewWidget = React.createClass({

  propTypes: {
  },

  mixins: [mixins.FluxMixin],

  getInitialState() {
    return {
      widgetType: "none"
    };
  },

  showForm() {
    var widgetType = React.findDOMNode(this.refs.picker).value
    this.setState( {widgetType: widgetType} );
  },

  getStore() {
    return this.getFlux().store("WidgetStore");
  },

  addMetadata(data) {
    var store = this.getStore();
    data.page_id = store.page_id;
    data.page_type = store.page_type;
  },

  submitData(formProps, data) {
    this.addMetadata(data);
    this.getFlux().actions.createWidget(data);
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
        return (<TextBodyWidgetForm submitData={this.submitData}></TextBodyWidgetForm>)
      case "RawHtmlWidget":
        return (<RawHtmlWidgetForm submitData={this.submitData}></RawHtmlWidgetForm>)
      default:
        return "Pick a widget type to create a new widget!"
    }
  },

  render(){
    return (
      <div className='widget'>
        <div className='widget-header'>
          <div className="widget-title">
            New Widget
          </div>
        </div>
        <div className="widget-edit">
          { this.picker() }
          { this.form() }
        </div>
      </div>
    )
  }
})

module.exports = NewWidget;