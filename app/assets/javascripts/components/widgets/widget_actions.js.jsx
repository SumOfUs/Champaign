var mixins = require('flux/mixins');

var WidgetActions = React.createClass({

  propTypes: {
    parentWidget:     React.PropTypes.object.isRequired,
    toggleEditShow:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
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
    this.getFlux().actions.destroyWidget(this.props.id);

    var node = React.findDOMNode(this.props.parentWidget);
    React.unmountComponentAtNode(node);
    $(node).remove();
  },

  render(){
    return (
      <div className='widget-header'>
        <div className='widget-actions'>
          <a onClick={this.handleEdit   } href='#'><span className='glyphicon glyphicon-pencil' /></a>
          <a onClick={this.handleDelete } href='#'><span className='glyphicon glyphicon-trash' /></a>
        </div>
        <div className='widget-title' />
      </div>
    )
  }
})

module.exports = WidgetActions
