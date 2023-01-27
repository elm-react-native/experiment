// @refresh reset

import React from 'react';
import {useCallback} from 'react';
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
  const [uri, setUri] = React.useState('');
  const [xhr, setXhr] = React.useState(null);

  const INJECTED_JAVASCRIPT = `(function() {
  const xhr = new XMLHttpRequest();
  xhr.open('GET', '${uri}');
  xhr.send();
  let received = 0;
  const send = function(msg) {
    window.ReactNativeWebView.postMessage(JSON.stringify({...msg, readyState: xhr.readyState}));
  };
  xhr.addEventListener('error', (err) => send({message:err.toString()}));
  xhr.addEventListener('load', () => send({load:true}));
  xhr.addEventListener('progress', () => {
    if (xhr.readyState === XMLHttpRequest.DONE) return;
    const newData = xhr.responseText.slice(received);
    if (newData.length) {
      send({newData});
      received += newData.length;
    }
  }, false);
})();`;

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
      setUri('about:blank');
      assStreamer.cancel();

      console.log('startSubtitle', arg);
      const xhr = new XhrProxy();
      setUri(arg.url);
      setXhr(xhr);

      assStreamer.start(arg.ratingKey, xhr, dialogues => {
        console.log(dialogues);
        ports.subtitleReceiver.send(dialogues);
      });
    });
    ports.stopSubtitle.subscribe(async () => {
      console.log('stopSubtitle');
      setUri('about:blank');
      assStreamer.cancel();
    });
  }, []);

  return (
    <React.StrictMode>
      <View>
        <WebView
          source={{html: uri}}
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
