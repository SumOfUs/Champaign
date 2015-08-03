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
      <label htmlFor="campaign_page_{this.props.label}" className="checkbox-inline">
        <input type="checkbox" checked={this.state.checked } onChange={ this.handleChange } ref="checkbox" /> {this.props.label}
      </label>
    )
  }
});


module.exports = CheckBox;
