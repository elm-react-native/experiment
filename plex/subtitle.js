import React from 'react';
import {useRef, useState} from 'react';
import {View} from 'react-native';
import {WebView} from 'react-native-webview';
import {useCallback, useEffect} from 'react';
import AssStreamer from './ass-streamer';

export default props => {
  const webViewRef = useRef(null);
  const [loaded, setLoaded] = useState(false);

  const assStreamerRef = useRef(new AssStreamer());
  const onMessage = useCallback(({nativeEvent}) => {
    if (!assStreamerRef.current) return;
    const xhrProxy = assStreamerRef.current.xhrProxy;

    const data = JSON.parse(nativeEvent.data);
    if (data.newData) {
      xhrProxy.receiveNewData(data.newData, data.readyState);
    } else if (data.error) {
      xhrProxy.errorOccur(data.message, data.readyState);
    } else if (data.load) {
      xhrProxy.loaded(data.readyState);
    }
  }, []);

  const sendStartStreamSubtitle = useEffect(() => {
    console.log('sendStartStreamSubtitle', props, loaded);

    if (!webViewRef.current || !assStreamerRef.current || !loaded) return;
    if (!props.url) {
      assStreamerRef.current.cancel();
      webViewRef.current.postMessage(JSON.stringify({type: 'stop'}));
      return;
    }

    assStreamerRef.current.start(new XhrProxy(), dialogues => {
      console.log(dialogues);
      props.onDialogues && props.onDialogues(dialogues);
    });

    webViewRef.current.postMessage(
      JSON.stringify({type: 'start', url: props.url}),
    );
    return () => {
      assStreamerRef.current.cancel();
    };
  }, [props.url, props.playbackTime, loaded]); // restart when playbackTime changes

  const onLoad = useCallback(() => {
    console.log('loaded');
    setLoaded(true);
  }, []);

  return (
    <View style={{width: 0, height: 0, overflow: 'hidden'}}>
      <WebView
        ref={webViewRef}
        source={{html: 'subtitle'}}
        injectedJavaScriptBeforeContentLoaded={INJECTED_JAVASCRIPT}
        onMessage={onMessage}
        onLoad={onLoad}
      />
    </View>
  );
};

const INJECTED_JAVASCRIPT = `
(function () {
  const send = function (msg) {
    window.ReactNativeWebView.postMessage(
      JSON.stringify(msg),
    );
  };

  let stopStreamSubtitle;

  window.onmessage = msg => {
    const action = JSON.parse(msg.data);
    if (action.type === 'start') {
      if (stopStreamSubtitle) stopStreamSubtitle();
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
    xhr.addEventListener('error', err => send({readyState: xhr.readyState, message: err.toString()}));
    xhr.addEventListener('load', () => send({readyState: xhr.readyState, load: true}));
    xhr.addEventListener(
      'progress',
      () => {
        if (xhr.readyState === XMLHttpRequest.DONE) return;
        const newData = xhr.responseText.slice(received);
        if (newData.length) {
          send({readyState: xhr.readyState, newData});
          received += newData.length;
        }
      },
      false,
    );
    return () => xhr.abort();
  }
})();`;

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
