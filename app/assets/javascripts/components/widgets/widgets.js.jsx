var ThermometerWidgetForm  = require('components/widgets/thermometer/form');
var TextBodyWidgetForm     = require('components/widgets/text_body/form');
var PetitionWidgetForm     = require('components/widgets/petition/form');
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
          return (<TextBodyWidgetForm {...widget} />)
        case "RawHtmlWidget":
          return (<RawHtmlWidgetForm {...widget} />)
        case "ThermometerWidget":
          return (<ThermometerWidgetForm {...widget} />)
        case "PetitionWidget":
          return (<PetitionWidgetForm {...widget} />)
        default:
          break;
      }
    })

    return (
      <div className="widgets">
        { widgets }
        <NewWidgetForm />
      </div>
    )
  }
});

module.exports = Widgets;
