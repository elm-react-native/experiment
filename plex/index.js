// @refresh reset

import React from 'react';
import {useCallback, useEffect, useState, useRef} from 'react';
import {
  View,
  AppRegistry,
  Platform,
  LogBox,
  NativeModules,
  Animated,
  StyleSheet,
  requireNativeComponent,
} from 'react-native';
import {
  GestureHandlerRootView,
  GestureDetector,
  Gesture,
} from 'react-native-gesture-handler';
import {name as appName} from './app.json';
import App from '@elm-module/Plex';
import vectorIconsResolveComponent from '@elm-react-native/react-native-vector-icons';
import contextMenuResolveComponent from '@elm-react-native/react-native-ios-context-menu';
import sliderResolveComponent from '@elm-react-native/react-native-slider';
import SubtitleStream from './subtitle';
import blurResolveComponent from '@elm-react-native/react-native-blur';
import {BlurView} from '@react-native-community/blur';
import pickerResolveComponent from '@elm-react-native/react-native-picker';

const NativeVideoView = requireNativeComponent('VideoView');
const VideoView = props => {
  const handleProgress = useCallback(
    event => {
      props.onProgress && props.onProgress(event.nativeEvent);
    },
    [props.onProgress],
  );
  return (
    <NativeVideoView
      {...props}
      onProgress={props.onProgress && handleProgress}
    />
  );
};

LogBox.ignoreLogs(['Could not find Fiber with id']);

AppRegistry.registerComponent(appName, () => () => {
  return (
    <React.StrictMode>
      <GestureHandlerRootView style={{flex: 1}}>
        <App
          resolveComponent={tag => {
            if (tag === 'SubtitleStream') return SubtitleStream;
            if (tag === 'PinchableView') return PinchableView;
            if (tag === 'ModalFadeView') return ModalFadeView;
            if (tag === 'VideoView') return VideoView;
            return (
              vectorIconsResolveComponent(tag) ||
              contextMenuResolveComponent(tag) ||
              sliderResolveComponent(tag) ||
              blurResolveComponent(tag) ||
              pickerResolveComponent(tag)
            );
          }}
        />
      </GestureHandlerRootView>
    </React.StrictMode>
  );
});

const PinchableView = ({onTap, onPinch, ...props}) => {
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

const ModalFadeView = ({visible, contentContainerStyle, ...props}) => {
  const animatedRef = React.useRef(new Animated.Value(0));
  const [actualVisible, setActualVisible] = React.useState(visible);

  useEffect(() => {
    console.log('ModalFadeView', visible);

    animatedRef.current.setValue(visible ? 0 : 1);
    setActualVisible(true);

    Animated.timing(animatedRef.current, {
      toValue: visible ? 1 : 0,
      duration: 200,
      useNativeDriver: true,
    }).start(({finished}) => {
      setActualVisible(visible);
    });
  }, [visible]);

  return (
    actualVisible && (
      <Animated.View
        style={StyleSheet.compose(contentContainerStyle, {
          opacity: animatedRef.current,
          flex: 1,
          transform: [
            {
              translateY: Animated.multiply(
                Animated.subtract(1, animatedRef.current),
                30,
              ),
            },
          ],
        })}>
        <BlurView {...props} />
      </Animated.View>
    )
  );
};
