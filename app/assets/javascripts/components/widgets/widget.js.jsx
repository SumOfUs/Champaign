var Widget = React.createClass({

  propTypes: {
    form:    React.PropTypes.func.isRequired,
    display: React.PropTypes.func.isRequired,
  },

  getInitialState() {
    return { edit: false };
  },

  toggleEditShow() {
    this.setState( {edit: !this.state.edit} );
  },

  form() {
    if(this.state.edit) { return this.props.form() }
  },

  display() {
    if(!this.state.edit) { return this.props.display() }
  },

  render(){
    var [form, display] = [this.form(), this.display()]
    return (
      <div className='widget'>
        <WidgetActions {...this.props} toggleEditShow={this.toggleEditShow} parentWidget={this}>
        </WidgetActions>
        { form }
        { display }
      </div>
    )
  }
})

var WidgetActions = React.createClass({

  propTypes: {
    parentWidget:     React.PropTypes.object.isRequired,
    toggleEditShow:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  getInitialState() {
    return { edit: false };
  },

  handleEdit(e){
    e.preventDefault();
    this.props.toggleEditShow();
  },

  handleDelete(e){
    e.preventDefault();

    $.ajax({
      url: "/campaign_pages/" + this.props.campaign_page_id + "/widgets/" + this.props.id,
      type: 'DELETE'
    })

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
