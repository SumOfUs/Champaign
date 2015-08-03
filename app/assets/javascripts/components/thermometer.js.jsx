
let PluginAttribute = React.createClass({
  handleChange(e) {
    this.setState({value: e.target.value});
    console.log('state;', this.state);
    window.state = this.state;
  },

  render() {
    let field_name = [this.props.plugin_name, '[', this.props.name, ']'].join('');

    return(
      <div className="col-xs-2">
        <input type="text"
               onChange={this.handleChange}
               ref={this.props.name}
               name={field_name}
               className="form-control"
               placeholder={this.props.label} />

      </div>
    )
  }
});

let Plugin = React.createClass({
  onSubmit(e) {
    e.preventDefault();
    let data = {};
    this.props.handleSubmit( data );
  },


  render() {
    let fields = this.props.attributes.map(function(attr){
      return( <PluginAttribute {...attr} plugin_name={this.props.name} /> )
    }.bind(this));

    return(
      <div className='component'>
        <h4>{this.props.display_name}</h4>
        <form onSubmit={this.onSubmit}>
          <div className="row">
            { fields }
            <div className="col-xs-2">
              <button className='btn btn-default'>Save</button>
            </div>
          </div>
        </form>
      </div>
    )
  }
});

let Plugins = React.createClass({
  handleSubmit(data) {
  },

  render() {
    let plugins = this.props.plugins.map(function(d){
      return <Plugin {...d} handleSubmit={this.handleSubmit} />
    }.bind(this));

    return(
      <div className='plugins'>
        { plugins }
      </div>
    );
  }
});

module.exports = Plugins;
