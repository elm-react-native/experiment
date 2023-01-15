// @refresh reset

import React from 'react';
import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';
import Video from 'react-native-video';

AppRegistry.registerComponent(appName, () => () => (
  <App
    resolveComponent={tag => {
      if (tag === 'Video') return VideoPlayer;
    }}
  />
));

const VideoPlayer = props => {
  // console.log('VideoPlayer props: ', props);

  const ref = React.useRef(null);

  React.useEffect(() => {
    if (props.fullscreen) {
      console.log(
        'presentFullscreenPlayer',
        ref.current.presentFullscreenPlayer,
      );
      ref.current.presentFullscreenPlayer();
    } else {
      console.log('dismissFullscreenPlayer');
      ref.current.dismissFullscreenPlayer();
    }
  }, [props.fullscreen]);
  React.useEffect(() => {
    if (props.seekOnStart) {
      ref.current.seek(props.seekOnStart / 1000);
    }
  }, []);
  return <Video ref={ref} {...props} />;
};
