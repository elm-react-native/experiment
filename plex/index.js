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
import AssStreamer from './ass-streamer';
import {WebView} from 'react-native-webview';

LogBox.ignoreLogs(['Could not find Fiber with id']);

class XhrProxy {
  _onerror = null;
  _onload = null;
  _onprogress = null;
  responseText = '';
  readyState = 0;
  addEventListener(name, fn) {
    if (name === 'progress') {
      this._onprogress = fn;
    } else if (name === 'load') {
      this._onload = fn;
    } else if (name === 'error') {
      this._onerror = fn;
    }
  }

  receiveNewData(newData, readyState) {
    this.responseText += newData;
    this._onprogress();
  }

  errorOccur(message, readyState) {
    this.readyState = readyState;
    this._onerror({message});
  }

  loaded(readyState) {
    this.readyState = readyState;
    this._onload();
  }
}

AppRegistry.registerComponent(appName, () => () => {
  const [xhr, setXhr] = useState(null);
  const webViewRef = useRef(null);

  const INJECTED_JAVASCRIPT = `
(function () {
  let stopStreamSubtitle;

  window.onmessage = msg => {
    const action = JSON.parse(msg.data);
    if (action.type === 'start') {
      stopStreamSubtitle = streamSubtitle(action.url);
    } else if (action.type === 'stop') {
      if (stopStreamSubtitle) stopStreamSubtitle();
    }
  };

  function streamSubtitle(url) {
    const xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.send();
    let received = 0;
    const send = function (msg) {
      window.ReactNativeWebView.postMessage(
        JSON.stringify({...msg, readyState: xhr.readyState}),
      );
    };
    xhr.addEventListener('error', err => send({message: err.toString()}));
    xhr.addEventListener('load', () => send({load: true}));
    xhr.addEventListener(
      'progress',
      () => {
        if (xhr.readyState === XMLHttpRequest.DONE) return;
        const newData = xhr.responseText.slice(received);
        if (newData.length) {
          send({newData});
          received += newData.length;
        }
      },
      false,
    );
  }
})();`;

  const sendStartStreamSubtitle = useCallback(url => {
    if (!webViewRef.current) return;
    console.log('sendStartStreamSubtitle', url);
    webViewRef.current.postMessage(JSON.stringify({type: 'start', url}));
  }, []);

  const sendStopStreamSubtitle = useCallback(() => {
    console.log('sendStopStreamSubtitle');

    if (!webViewRef.current) return;
    webViewRef.current.postMessage(JSON.stringify({type: 'stop'}));
  }, []);

  const onSubtitleMessage = useCallback(
    ({nativeEvent}) => {
      const data = JSON.parse(nativeEvent.data);
      if (data.newData) {
        xhr.receiveNewData(data.newData, data.readyState);
      } else if (data.error) {
        xhr.errorOccur(data.message, data.readyState);
      } else if (data.load) {
        xhr.loaded(data.readyState);
      }
    },
    [xhr],
  );

  const onAppInit = useCallback(async ({ports}) => {
    const assStreamer = new AssStreamer();

    ports.startSubtitle.subscribe(async arg => {
      assStreamer.cancel();
      sendStopStreamSubtitle();

      console.log('startSubtitle', arg);
      sendStartStreamSubtitle(arg.url);
      const xhr = new XhrProxy();
      setXhr(xhr);

      assStreamer.start(arg.ratingKey, xhr, dialogues => {
        console.log(dialogues);
        ports.subtitleReceiver.send(dialogues);
      });
    });
    ports.stopSubtitle.subscribe(async () => {
      console.log('stopSubtitle');
      assStreamer.cancel();
      sendStopStreamSubtitle();
    });
  }, []);

  return (
    <React.StrictMode>
      <View style={{width: 0, height: 0, overflow: 'hidden'}}>
        <WebView
          ref={webViewRef}
          source={{html: 'subtitle'}}
          injectedJavaScriptBeforeContentLoaded={INJECTED_JAVASCRIPT}
          onMessage={onSubtitleMessage}
        />
      </View>

      <App
        onInit={onAppInit}
        resolveComponent={tag => {
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
