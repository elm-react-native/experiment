// @refresh reset

import React from 'react';
import {AppRegistry, Platform} from 'react-native';
import App from './App';
import {name as appName} from './app.json';
import {Picker, PickerIOS} from '@react-native-picker/picker';
import Video from 'react-native-video';

AppRegistry.registerComponent(appName, () => () => (
  <App
    resolveComponent={tag => {
      if (tag === 'Video') return VideoPlayer;
      if (tag === 'Picker') {
        return [Picker, Picker.Item];
      }
    }}
  />
));

const VideoPlayer = props => {
  // console.log('VideoPlayer props: ', props);
  const ref = React.useRef(null);

  React.useEffect(() => {
    if (props.seekOnStart) {
      ref.current.seek(props.seekOnStart / 1000);
    }
  }, []);

  return <Video ref={ref} {...props} />;
};
