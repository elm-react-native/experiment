import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';
import Video from 'react-native-video';

AppRegistry.registerComponent(appName, () => () => (
  <App
    resolveComponent={tag => {
      if (tag === 'Video') return Video;
    }}
  />
));
