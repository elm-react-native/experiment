// @refresh reset

import React from 'react';
import {AppRegistry, Platform, LogBox} from 'react-native';
import {name as appName} from './app.json';
import App from '@elm-module/Plex';
import vectorIconsResolveComponent from '@elm-react-native/react-native-vector-icons';
import contextMenuResolveComponent from '@elm-react-native/react-native-ios-context-menu';
import videoResolveComponent from '@elm-react-native/react-native-video';

LogBox.ignoreLogs(['Could not find Fiber with id']);

AppRegistry.registerComponent(appName, () => () => (
  <React.StrictMode>
    <App
      resolveComponent={tag => {
        return (
          vectorIconsResolveComponent(tag) ||
          contextMenuResolveComponent(tag) ||
          videoResolveComponent(tag)
        );
      }}
    />
  </React.StrictMode>
));
