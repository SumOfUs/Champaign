
let Content = React.createClass({
  getInitialState() {
    return { saving: false, just_saved: false }
  },

  componentDidMount() {
    let configs = {
      theme: 'snow',
      modules: {
        'toolbar': { container: '#toolbar' },
        'link-tooltip': true
      }
    };

    this.quill = new Quill('#editor', configs);
    this.quill.setHTML(this.props.content)
  },

  handleSubmit(e) {
    e.preventDefault();
    this.saveContent()
  },

  saveContent() {
    let content = this.quill.getHTML();

    $.ajax({
      data: {campaign_page: {content: content} },
      url: "/campaign_pages/" + this.props.id,
      type: "PUT",
      beforeSend: () => this.setState({saving: true, just_saved: false})
    }).done( d => {
      this.setState({'saving': false, just_saved: true});
    }.bind(this));

  },

  form(){
    return(
      '<div id="toolbar">' +
        '<div class="ql-format-group">' +
          '<span title="Bold" class="ql-format-button ql-bold"></span>'     +
          '<span title="Italic" class="ql-format-button ql-italic"></span>' +
          '<span title="Bullet" class="ql-format-button ql-bullet"></span>' +
          '<span title="List" class="ql-format-button ql-list"></span>'     +
          '<span title="Link" class="ql-format-button ql-link"></span>'     +
        '</div>' +
      '</div>' +
      '<div id="editor">' +
        '<div></div>' +
      '</div>'
    )
  },

  render() {
    let styles = {display: 'none'};
    let feedback = 'saving...';
    let feedbackClass = 'feedback';

    if(this.state.just_saved){
      feedback = 'saved!';
      feedbackClass += ' just-saved';
    }

    if( this.state.saving || this.state.just_saved ){
      styles.display = 'block';
    }

    return (
      <div>
        <form onSubmit={this.handleSubmit}>
          <div dangerouslySetInnerHTML={{__html: this.form()}} />
          <div className="form-footer clearfix">
            <button className='btn btn-default'>Save</button>
            <h3 className={feedbackClass} style={ styles }><span className="label label-success" >{feedback}</span></h3>
          </div>
        </form>
        <div className='photo-upload well clearfix'>
          <div className='' >
            <div className=''>
              <img width='200' src='http://img1.ndsstatic.com/wallpapers/7b1d7791561595573b013c35fc0ce592_large.jpeg' />
            </div>
            <span className='notice'>
              Drag photos here or click to upload.
            </span>
          </div>
        </div>
      </div>
    );
  }
});

module.exports = Content;

