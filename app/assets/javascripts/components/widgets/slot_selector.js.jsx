var SlotSelector = React.createClass({

  propTypes: {
    page_display_order: React.PropTypes.number
  },

  options() {
    let order = 0;
    return window.slotNames.map(label =>{
      order++;
      return (<option value={order}> { label } </option>)
    });
  },

  serialize() {
    var pdo = React.findDOMNode(this.refs.picker).value;
    return {page_display_order: pdo}
  },

  render() {
    return (
      <div className="form-group">
        <label>Slot</label>
        <select ref='picker' defaultValue={this.props.page_display_order} onChange={this.showForm}>
          { this.options() }
        </select>
      </div>
    )
  }
});

module.exports = SlotSelector;
