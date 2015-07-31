var DemoComponent = require('../demo_component.js');

console.log("llo");

jest.dontMock('../demo_component.js');

describe('DemoComponents', function() {
  it('works', function(){
    expect(1).toBe(1);
  });
});


console.log("raa", DemoComponent.name);

//describe('DemoComponent', function() {
  //it('works', function(){
    //expect(1).toBe(1);
  //});

  //it('should tell use it is a demo component', function() {
    //var React = require('react/addons');
    //var TestUtils = React.addons.TestUtils;
    //var DemoComponent = require('DemoComponent');
    //var demoComponent = TestUtils.renderIntoDocument(<DemoComponent/>);
    //expect(demoComponent.getDOMNode().textContent).toBe('Demo Component');
  //});
//});
