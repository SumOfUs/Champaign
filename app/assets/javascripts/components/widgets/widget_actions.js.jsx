var mixins = require('flux/mixins');

var WidgetActions = React.createClass({

  propTypes: {
    parentWidget:     React.PropTypes.object.isRequired,
    toggleEditShow:   React.PropTypes.func.isRequired,
    title:            React.PropTypes.string,
    id:               React.PropTypes.number.isRequired,
    page_display_order: React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  getInitialState() {
    return { edit: false };
  },

  handleEdit(e){
    e.preventDefault();
    this.props.toggleEditShow();
  },

  handleDelete(e){
    e.preventDefault();

    var store = this.getFlux().store("WidgetStore");
    this.getFlux().actions.destroyWidget({id: this.props.id, page_id: store.page_id, page_type: store.page_type});

    var node = React.findDOMNode(this.props.parentWidget);
    React.unmountComponentAtNode(node);
    $(node).remove();
  },

  slotLabel() {
    if (window.slotNames && this.props.page_display_order) {
      return window.slotNames[this.props.page_display_order-1]
    } else {
      return "";
    }
  },

  render(){
    return (
      <div className='widget-header'>
        <div className="widget-title">
          { this.slotLabel() } - { this.props.title }
        </div>
        <div className='widget-actions'>
          <a onClick={this.handleEdit   } href='#'><span className='glyphicon glyphicon-pencil' /></a>
          <a onClick={this.handleDelete } href='#'><span className='glyphicon glyphicon-trash' /></a>
        </div>
      </div>
    )
  }
})

module.exports = WidgetActions
