var WidgetFormErrors = require('components/widgets/widget_form_errors');
var SlotSelector     = require('components/widgets/slot_selector');
var mixins = require('flux/mixins');

var ThermometerWidgetFields = React.createClass({

  propTypes: {
    goal:               React.PropTypes.number,
    page_display_order: React.PropTypes.number,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  serialize() {
    var goal = React.findDOMNode(this.refs.goal).value;
    var pdo = this.refs.slotSelector.serialize().page_display_order;
    return {page_display_order: pdo, goal: goal, type: 'ThermometerWidget' };
  },

  handleSubmit(e) {
    e.preventDefault();
    this.props.submitData(this.props, this.serialize());
  },

  render() {
    return (
      <div className='widget-html-form'>
         <form onSubmit={ this.handleSubmit }>
          <WidgetFormErrors errors={this.props.errors} />
          <SlotSelector ref="slotSelector" page_display_order={this.props.page_display_order} />
          <div className="form-group">
            <label htmlFor="">Goal</label>
            <input type='number' className='form-control' ref='goal' defaultValue={this.props.goal}></input>
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})

module.exports = ThermometerWidgetFields;
