let CheckBox = React.createClass({
  getInitialState() {
    return (
      { checked: this.props.checked }
    )
  },

  handleChange() {
    let checked = React.findDOMNode(this.refs.checkbox).checked

    let data = {}
    data[this.props.name] = checked
    this.props.onChange(data);
    this.setState( {checked: !this.state.checked } )
  },

  render() {
    return (
      <div className="checkbox">
        <label htmlFor="campaign_page_{this.props.label}" className="control-label">
          <input type="checkbox" checked={this.state.checked } onChange={ this.handleChange } ref="checkbox" /> {this.props.label}
        </label>
      </div>
    )
  }
});

module.exports = CheckBox;