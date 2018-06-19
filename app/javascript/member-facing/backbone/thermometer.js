import _ from 'lodash';
import Backbone from 'backbone';

const Thermometer = Backbone.View.extend({
  // settings:
  //   goal_k: the goal as a user-friendly string, such as '35k'
  //   remaining: the number of signatures remaining before the target
  //   signatures: the number of signatures recieved already
  //   percentage: the percentage of the goal completed, eg '35.4'
  initialize(settings) {
    this.updateUi(settings);
  },

  updateUi(settings) {
    if (!_.isObject(settings) || _.keys(settings).length == 0) {
      return;
    }
    $('.thermometer__remaining').text(
      I18n.t('thermometer.signatures_until_goal', {
        goal: settings.goal_k,
        remaining: settings.remaining,
      })
    );
    $('.thermometer__signatures').text(
      `${settings.signatures} ${I18n.t('thermometer.signatures')}`
    );
    $('.thermometer__mercury').css('width', `${settings.percentage}%`);
  },
});

export default Thermometer;
