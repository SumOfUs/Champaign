var WidgetFormErrors = require('components/widgets/widget_form_errors');
var mixins = require('flux/mixins');

var ThermometerWidgetFields = React.createClass({

  propTypes: {
    goal:               React.PropTypes.string,
    page_display_order: React.PropTypes.number,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  serialize() {
    var goal = React.findDOMNode(this.refs.goal).value;
    var pdo  = React.findDOMNode(this.refs.pdo).value;
    return {goal: goal, page_display_order: pdo, type: 'ThermometerWidget' };
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
          <div className="form-group">
            <label htmlFor="">Slot</label>
            <input type='number' className='form-control' ref='pdo' defaultValue={this.props.page_display_order}></input>
          </div>
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

module.exports = ThermometerWidgetFields