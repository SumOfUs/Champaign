var ThermometerWidgetForm  = require('components/widgets/thermometer/form');
var TextBodyWidgetForm     = require('components/widgets/text_body/form');
var RawHtmlWidgetForm      = require('components/widgets/raw_html/form');
var NewWidgetForm          = require('components/widgets/new_widget_form');

var Widgets = React.createClass({

  propTypes: {
    widgets:          React.PropTypes.array.isRequired
  },

  render(){
    var widgets = this.props.widgets.map(widget => {
      switch (widget.type) {
        case "TextBodyWidget":
          return (<TextBodyWidgetForm {...widget}></TextBodyWidgetForm>)
        case "RawHtmlWidget":
          return (<RawHtmlWidgetForm {...widget}></RawHtmlWidgetForm>)
        case "ThermometerWidget":
          return (<ThermometerWidgetForm {...widget}></ThermometerWidgetForm>)
        default:
          break;
      }
    })

    return (
      <div className="widgets">
        { widgets }
        <NewWidgetForm>
        </NewWidgetForm>
      </div>
    )
  }
});

module.exports = Widgets;
