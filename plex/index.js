// @refresh reset

import React from 'react';
import {useCallback, useState, useRef} from 'react';
import {View, AppRegistry, Platform, LogBox, NativeModules} from 'react-native';
import {
  GestureHandlerRootView,
  GestureDetector,
  Gesture,
} from 'react-native-gesture-handler';
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
      <GestureHandlerRootView style={{flex: 1}}>
        <App
          resolveComponent={tag => {
            if (tag === 'SubtitleStream') return SubtitleStream;
            if (tag === 'PinchableView') return pinchableView;
            return (
              vectorIconsResolveComponent(tag) ||
              contextMenuResolveComponent(tag) ||
              videoResolveComponent(tag) ||
              sliderResolveComponent(tag)
            );
          }}
        />
      </GestureHandlerRootView>
    </React.StrictMode>
  );
});

const pinchableView = ({onTap, onPinch, ...props}) => {
  const ph = Gesture.Pinch().onStart(e => {
    // console.log('pinch');
    onPinch && onPinch(e.scale);
  });

  const tp = Gesture.Tap()
    .maxDuration(250)
    .onStart(e => {
      // console.log('tap');
      onTap && onTap();
    });

  return (
    <GestureDetector gesture={Gesture.Exclusive(ph, tp)}>
      <View
        style={{position: 'absolute', top: 0, left: 0, bottom: 0, right: 0}}
        {...props}
      />
    </GestureDetector>
  );
};
