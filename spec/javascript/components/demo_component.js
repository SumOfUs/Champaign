console.log('raa');
var React = require('react');

var DemoComponent = React.createClass({displayName: 'Demo Component',
  render: function() {
    return <div>Demo Component</div>;
  }
});


DemoComponent.name = "Omar"

module.exports = DemoComponent;
