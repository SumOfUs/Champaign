import Petition from './backbone/petition';
import PetitionAndScrollToConsent from './backbone/petition_and_scroll_to_consent';
import DoubleOptIn from './double_opt_in';
import Survey from './backbone/survey';
import ActionForm from './backbone/action_form';
import OverlayToggle from './backbone/overlay_toggle';
import Thermometer from './backbone/thermometer';
import Sidebar from './backbone/sidebar';
import Notification from './backbone/notification';
import SweetPlaceholder from './backbone/sweet_placeholder';
import CampaignerOverlay from './backbone/campaigner_overlay';

import './registration';
import './track_shares';
import './champaign';

Object.assign(window.champaign, {
  ActionForm,
  CampaignerOverlay,
  DoubleOptIn,
  Notification,
  OverlayToggle,
  Petition,
  PetitionAndScrollToConsent,
  Sidebar,
  Survey,
  SweetPlaceholder,
  Thermometer,
});
