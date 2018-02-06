import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

require('dotenv').config({ path: 'env.yml' });
require('../../app/javascript/shared/pub_sub');

configure({ adapter: new Adapter() });
