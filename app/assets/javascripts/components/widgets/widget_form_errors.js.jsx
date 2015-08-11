var WidgetFormErrors = React.createClass({

  propTypes: {
    errors:   React.PropTypes.object
  },

  renderErrors(){
    return Object.keys(this.props.errors).map(field => {
      let msg = `${field} ${this.props.errors[field][0]}`
      return( <li>{ msg }</li> )
    });
  },

  render() {
    if (!this.props.errors) { return false; }
    return (
      <div className="errors">
        <div className="error-header">
          We couldn't save because of these errors:
        </div>
        <ul>
          { this.renderErrors() }
        </ul>
      </div>
    )
  }
});

module.exports = WidgetFormErrors;