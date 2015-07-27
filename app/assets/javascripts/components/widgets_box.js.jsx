var WidgetsBox = React.createClass({
  getInitialState() {
    return { data: [] };
  },

  componentDidMount() {
    $.getJSON("/campaign_pages/" + this.props.campaign_page_id + "/widgets.json", function(data){
      this.setState({data: data});
    }.bind(this))
  },

  handleWidgetSubmit(data) {
    $.post( "/campaign_pages/" + this.props.campaign_page_id + "/widgets/html", data)
    .done(function( data ) {
      this.setState({data: this.state.data.concat([data])})
    }.bind(this));
  },

  render() {
    return (
      <div className='widgets'>
        <Widgets onWidgetSubmit={this.handleWidgetSubmit} widgets={this.state.data} campaign_page_id={ this.props.campaign_page_id } />
      </div>
    )
  }
})

var Widgets = React.createClass({
  render(){
    var widgets = this.props.widgets.map(widget => {
      switch (widget.type) {
        case "TextBodyWidget":
          return (<TextBodyWidget {...widget} onWidgetSubmit={this.props.onWidgetSubmit}></TextBodyWidget>)
        default:
          break;
      }
    })

    return (
      <div className="widgets">
        { widgets }
      </div>
    )
  }
})

var WidgetActions = React.createClass({
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

    var node = this.getDOMNode();
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

var TextBodyWidget = React.createClass({
  getInitialState() {
    return { edit: false };
  },

  toggleEditShow() {
    this.setState( {edit: !this.state.edit} );
  },

  render(){
    if (this.state.edit) {
      shown = <div className='widget-edit'>
         <TextWidgetForm {...this.props}>
         </TextWidgetForm>
       </div>
    } else {
      shown = <div className='widget-show'>
        {this.props.text_body_html}
      </div>
    }
    return (
      <div className="text-body-widget widget">
       <WidgetActions {...this.props} toggleEditShow={this.toggleEditShow}>
       </WidgetActions>
       { shown }
     </div>
    )
  }
})

var TextWidgetForm = React.createClass({

  handleSubmit(e) {
    e.preventDefault()
    var text = React.findDOMNode(this.refs.body).value
    var data = {text_body_html: text, text: text, type: 'TextBodyWidget', campaign_page_id: this.props.campaign_page_id }
    this.props.onWidgetSubmit(data);
  },

  render() {
    return (
      <div className='widget-html-form'>
         <form onSubmit={ this.handleSubmit }>
          <div className="form-group">
            <label htmlFor="">Text</label>
            <textarea className='form-control' ref='body' defaultValue={this.props.text_body_html}></textarea>
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})
