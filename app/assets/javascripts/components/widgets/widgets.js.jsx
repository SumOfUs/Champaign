var TextBodyWidget = require('components/widgets/text_body_widget');
var RawHtmlWidget  = require('components/widgets/raw_html_widget');
var NewWidget      = require('components/widgets/new_widget');

var Widgets = React.createClass({

  propTypes: {
    widgets:          React.PropTypes.array.isRequired
  },

  render(){
    var widgets = this.props.widgets.map(widget => {
      switch (widget.type) {
        case "TextBodyWidget":
          return (<TextBodyWidget {...widget}></TextBodyWidget>)
        case "RawHtmlWidget":
          return (<RawHtmlWidget {...widget}></RawHtmlWidget>)
        default:
          break;
      }
    })

    return (
      <div className="widgets">
        { widgets }
        <NewWidget>
        </NewWidget>
      </div>
    )
  }
});

module.exports = Widgets;
