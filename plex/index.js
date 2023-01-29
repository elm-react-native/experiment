// @refresh reset

import React from 'react';
import {useCallback, useState, useRef} from 'react';
import {View, AppRegistry, Platform, LogBox, NativeModules} from 'react-native';
import {name as appName} from './app.json';
import App from '@elm-module/Plex';
import vectorIconsResolveComponent from '@elm-react-native/react-native-vector-icons';
import contextMenuResolveComponent from '@elm-react-native/react-native-ios-context-menu';
import videoResolveComponent from '@elm-react-native/react-native-video';
import sliderResolveComponent from '@elm-react-native/react-native-slider';
import SubtitleStream from './subtitle';

LogBox.ignoreLogs(['Could not find Fiber with id']);

AppRegistry.registerComponent(appName, () => () => {
  return (
    <React.StrictMode>
      <App
        resolveComponent={tag => {
          if (tag === 'SubtitleStream') return SubtitleStream;
          return (
            vectorIconsResolveComponent(tag) ||
            contextMenuResolveComponent(tag) ||
            videoResolveComponent(tag) ||
            sliderResolveComponent(tag)
          );
        }}
      />
    </React.StrictMode>
  );
});
