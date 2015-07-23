class HelloMessage extends React.Component {
  render() {
    return (
      <div className="comment">
        <h2 className="commentAuthor">
          {this.props.name}
        </h2>
        <p>{this.props.message}</p>
      </div>
    );
  }
}

HelloMessage.defaultProps = { message: "BOOOOO" };

