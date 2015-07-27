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
        <Widgets widgets={this.state.data} campaign_page_id={ this.props.campaign_page_id } />
        <WidgetTextForm onWidgetSubmit={this.handleWidgetSubmit} page_id={ this.props.campaign_page_id }/>
      </div>
    )
  }
})

var Widgets = React.createClass({
  render(){
    var widgets = this.props.widgets.map(function (widget) {
      return (
        <Widget id={widget.id} campaign_page_id={ widget.campaign_page_id }>
          {widget.text_body_html}
        </Widget>
      )
    })

    return (
      <div className="widgets">
        { widgets }
      </div>
    )
  }
})

var Widget = React.createClass({
  getInitialState() {
    return { edit: false };
  },

  handleEdit(e){
    e.preventDefault();
    console.log('edit');
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
    var rawMarkup = marked(this.props.children.toString(), {sanitize: true});

    return (
      <div className="text-body-widget widget">
       <div className='widget-header'>
         <div className='widget-actions'>
           <a onClick={this.handleEdit   } href='#'><span className='glyphicon glyphicon-pencil' /></a>
           <a onClick={this.handleDelete } href='#'><span className='glyphicon glyphicon-trash' /></a>
         </div>
         <div className='widget-title' />
       </div>
       <div className='widget-content'>
         <span dangerouslySetInnerHTML={{__html: rawMarkup}} />
       </div>
       <div className='widget-edit' style={{ display: 'none' }} >

       <WidgetTextForm>
        { this.props.children }
       </WidgetTextForm>
       </div>
     </div>
    )
  }
})

var WidgetTextForm = React.createClass({
  getInitialState() {
    return { hide: true };
  },

  handleSubmit(e) {
    e.preventDefault()
    var text = React.findDOMNode(this.refs.body).value
    var data = {text_body_html: text, text: text, type: 'TextBodyWidget', campaign_page_id: this.props.page_id }
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
