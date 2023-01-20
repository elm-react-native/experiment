// @refresh reset

import React from 'react';
import {AppRegistry, Platform} from 'react-native';
// import App from './App';
import {name as appName} from './app.json';
import App from './src/Plex';
import vectorIconsResolveComponent from '@elm-react-native/react-native-vector-icons';
import contextMenuResolveComponent from '@elm-react-native/react-native-ios-context-menu';
import videoResolveComponent from '@elm-react-native/react-native-video';

AppRegistry.registerComponent(appName, () => () => (
  <App
    resolveComponent={tag => {
      return (
        vectorIconsResolveComponent(tag) ||
        contextMenuResolveComponent(tag) ||
        videoResolveComponent(tag)
      );
    }}
  />
));
