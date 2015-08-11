jest.dontMock('../hello.js');

describe('Hello', function() {

  it('renders welcome message', function() {
    var React = require('react/addons');
    var Hello = require('../hello.js');
    var TestUtils = React.addons.TestUtils;

    var El = TestUtils.renderIntoDocument(
      <Hello name={'Bob'} />
    );

    expect(El.getDOMNode().textContent).toEqual('Hello, Bob!');
  });
});
