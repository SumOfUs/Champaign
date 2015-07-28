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
    $.ajax({
      type: "PUT",
      url: "/campaign_pages/" + this.props.campaign_page_id + "/widgets/" + data.widget.id,
      data: data
    }).done(function( data ) {
      this.setState({data: data})
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

  propTypes: {
    widgets:          React.PropTypes.array.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired
  },

  render(){
    var widgets = this.props.widgets.map(widget => {
      switch (widget.type) {
        case "TextBodyWidget":
          return (<TextBodyWidget {...widget} onWidgetSubmit={this.props.onWidgetSubmit}></TextBodyWidget>)
        case "RawHtmlWidget":
          return (<RawHtmlWidget {...widget} onWidgetSubmit={this.props.onWidgetSubmit}></RawHtmlWidget>)
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

var TextBodyWidget = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form() {
    return (
      <div className='widget-edit'>
        <TextBodyWidgetForm {...this.props}>
        </TextBodyWidgetForm>
      </div>
    )
  },

  display() {
    return (
      <div className='widget-show'>
        {this.props.text_body_html}
      </div>
    )
  },

  render() {
    return (
      <div className="text-body-widget">
        <Widget {...this.props} form={this.form} display={this.display}>
        </Widget>
      </div>
    )
  }
})

var TextBodyWidgetForm = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  handleSubmit(e) {
    e.preventDefault()
    var text = React.findDOMNode(this.refs.body).value
    var data = { widget: {text_body_html: text, text: text, type: 'TextBodyWidget', campaign_page_id: this.props.campaign_page_id, id: this.props.id } }
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

var RawHtmlWidget = React.createClass({

  propTypes: {
    html:             React.PropTypes.string.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form() {
    return (
      <div className='widget-edit'>
        <RawHtmlWidgetForm {...this.props}>
        </RawHtmlWidgetForm>
      </div>
    )
  },

  display() {
    return (
      <div className='widget-show'>
        {this.props.html}
      </div>
    )
  },

  render() {
    return (
      <div className="text-body-widget">
        <Widget {...this.props} form={this.form} display={this.display}>
        </Widget>
      </div>
    )
  }
})

var RawHtmlWidgetForm = React.createClass({

  propTypes: {
    html:             React.PropTypes.string.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  handleSubmit(e) {
    e.preventDefault()
    var text = React.findDOMNode(this.refs.body).value
    var data = { widget: {html: text, text: text, type: 'RawHtmlWidget', campaign_page_id: this.props.campaign_page_id, id: this.props.id } }
    this.props.onWidgetSubmit(data);
  },

  render() {
    return (
      <div className='widget-html-form'>
         <form onSubmit={ this.handleSubmit }>
          <div className="form-group">
            <label htmlFor="">Text</label>
            <textarea className='form-control' ref='body' defaultValue={this.props.html}></textarea>
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})
