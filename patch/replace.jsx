
var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
  return F2(function(factList, kidList)
  {
    if (/\.Screen$/.test(tag))
    {
      // delay to navigator component
      return {tag, factList, kidList};
    }
    else if (tag === "RefreshControl")
    {
      return {tag, factList, kidList}
    }
    else if (tag === "Stack.Navigator")
    {
      return <NavigatorComponent tag={tag} factList={factList} kidList={kidList} />;
    }
    else if (tag === "SectionList")
    {
      return <SectionListComponent factList={factList} kidList={kidList} />;
    }
    else if (tag === "FlatList")
    {
      return <FlatListComponent factList={factList} kidList={kidList} />;
    }
    return <ElmNodeComponent tag={tag} factList={factList} kidList={kidList} />;
  });
});

var _VirtualDom_map = F2(function(tagger, node)
{
  return <ElmMapComponent tagger={tagger} node={node} />;
});

function _VirtualDom_text(string)
{
  if (scope.isReactNative) {
    return <ElmNodeComponent tag="Text" factList={_List_Nil} kidList={_List_Cons(string, _List_Nil)} />
  }
  return string;
}

var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
  return F2(function(factList, kidList)
  {
    if (/\.Screen$/.test(tag))
    {
      // delay to navigator component
      return {tag, factList, kidList};
    }
    else if (tag === "Stack.Navigator")
    {
      return <NavigatorComponent tag={tag} factList={factList} kidList={kidList} />;
    }
    else if (tag === "SectionList")
    {
      return <SectionListComponent factList={factList} kidList={kidList} />;
    }
    else if (tag === "FlatList")
    {
      return <FlatListComponent factList={factList} kidList={kidList} />;
    }
    return <ElmKeyedNodeComponent tag={tag} factList={factList} kidList={kidList} />;
  });
});

function _VirtualDom_thunk(refs, thunk)
{
  return <ElmThunkComponent refs={refs} thunk={thunk} />;
}


var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
  return _Platform_initialize(
    flagDecoder,
    args,
    impl.init,
    impl.update,
    impl.subscriptions,
    function(sendToApp, initialModel) {
      args.onInit(initialModel, impl.view, sendToApp);
      return _Browser_makeAnimator(initialModel, args.onModelChanged);
    }
  );
});

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
  return _Platform_initialize(
    flagDecoder,
    args,
    (flags) => impl.init(flags, args.navigation),
    impl.update,
    impl.subscriptions,
    function(sendToApp, initialModel) {
      var divertHrefToApp = impl.setup && impl.setup(sendToApp)
      var view = impl.view;
      var title = _VirtualDom_doc.title;

      args.onInit(initialModel, impl.view, sendToApp, title);
      return _Browser_makeAnimator(initialModel, function(model)
      {
        _VirtualDom_divertHrefToApp = divertHrefToApp;
        args.onModelChanged(model);
        _VirtualDom_divertHrefToApp = 0;
      });
    }
  );
});

function _Browser_application(impl)
{
  return _Browser_document({
    init: function(flags, navigation)
    {
      return A3(impl.init, flags, "", navigation);
    },
    view: impl.view,
    update: impl.update,
    subscriptions: impl.subscriptions
  });
}

var $author$project$ReactNative$ActionSheetIOS$show = F2(
  function (options, props) {
    return _Scheduler_binding(function(callback) {
      const opts = { options: _List_toArray(options) };
      for (; props.b; props = props.b) {
        const p = props.a;
        let k = p.a;
        let v = _Json_unwrap(p.b);

        if (k === "disabledButtonIndices") {
          v = _List_toArray(v);
        } else if (k === "destructiveButtonIndices") {
          k = "destructiveButtonIndex";
          v = _List_toArray(v);
        }

        opts[k] = v;
      }

      ActionSheetIOS.showActionSheetWithOptions(opts, (buttonIndex) => { callback(_Scheduler_succeed(buttonIndex)) });
    });
  });

var $author$project$ReactNative$Alert$alert = F2(
  function (title, props) {
    return _Scheduler_binding(function(callback) {
      let buttons = undefined;
      const options = {};
      let message = undefined;
      for (; props.b; props = props.b) {
        const p = props.a;
        const k = p.a;
        let v = _Json_unwrap(p.b);
        if (k === "buttons") {
          for (; v.b; v = v.b) {
            const btn = v.a;
            buttons = buttons || [];
            buttons.push({
              ...btn,
              onPress: () => { callback(_Scheduler_succeed(btn.onPress)) },
            });
          }
        } else if (k === "message") {
          message = v;
        } else {
          options[k] = v;

          if (k === "cancelable" && v) {
            options.onDismiss = () => { callback(_Scheduler_succeed($author$project$ReactNative$Alert$Dismiss)) };
          }
        }
      }
      Alert.alert(title, message, buttons, options);
    });
  });

var _Browser_go = F2(function(key, n)
{
  return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
    key.goBack();
  }));
});

var $author$project$ReactNative$BackHandler$exitApp = function () {
  return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
    BackHandler.exitApp();
  }));
}();

var $author$project$ReactNative$DynamicColorIOS$setWithHighContrast = F4(
  function (light, dark, highContrastLight, highContrastDark) {
    return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
      if (Platform.os === "ios") {
        DynamicColorIOS({light, dark, highContrastLight: highContrastLight.a, highContrastDark: highContrastDark.a});
      }
    }));
  });

var $author$project$ReactNative$Navigation$push = F3(
  function (k, s, p) {
    return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
      if (k.isReady()) {
        k.dispatch(StackActions.push(s, p));
      }
    }));
  });

var _Browser_replaceUrl = F2(function(key, url)
{
  return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
    if (key.isReady()) {
      key.navigate(url);
    }
  }));
});

var $author$project$ReactNative$StyleSheet$compose = F2(
  function (a, b) {
    return StyleSheet.compose(a, b);
  });

var $author$project$ReactNative$StyleSheet$compose3 = F3(
  function (a, b, c) {
    return StyleSheet.flatten([a, b, c]);
  });

var $author$project$ReactNative$Vibrate$cancel = function () {
  return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
    Vibration.cancel();
  }));
}();

var $author$project$ReactNative$Vibrate$once = function () {
  return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
    Vibration.vibrate();
  }));
}();

var $author$project$ReactNative$Vibrate$vibrate = F2(
  function (p, b) {
    return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
      Vibration.vibrate(_List_toArray(p), b);
    }));
  });

var $author$project$ReactNative$Animated$create = function (x) {
  return new Animated.Value(x);
};

var $author$project$ReactNative$Animated$createXY = F2(
  function (x, y) {
      return new Animated.ValueXY({x, y});
  });

var $author$project$ReactNative$Animated$timing = F2(
  function (cfg, v) {
    if (typeof cfg.useNativeDrivder === 'undefined') cfg.useNativeDriver = false;
    return Animated.timing(v, cfg);
  });

var $author$project$ReactNative$Animated$spring = F2(
  function (cfg, v) {
    if (typeof cfg.useNativeDrivder === 'undefined') cfg.useNativeDriver = false;
    return Animated.spring(v, cfg);
  });

var $author$project$ReactNative$Animated$decay = F2(
  function (cfg, v) {
    if (typeof cfg.useNativeDrivder === 'undefined') cfg.useNativeDriver = false;
    return Animated.decay(v, cfg);
  });

var $author$project$ReactNative$Animated$start = function (v) {
  return _Scheduler_binding(function(callback) {
    v.start((res) => {
      callback(_Scheduler_succeed(res));
    });
  });
};

var $author$project$ReactNative$Animated$reset = function (v) {
  return _Scheduler_binding(function(callback) {
    v.reset();
    callback(_Scheduler_succeed(_Utils_Tuple0));
  });
};

var $author$project$ReactNative$Animated$interpolate = F2(
  function (cfg, v) {
    return v.interpolate({
      ...cfg,
      inputRange: _List_toArray(cfg.inputRange),
      outputRange: _List_toArray(cfg.outputRange),
    });
  });

var $author$project$ReactNative$Animated$stop = function (v) {
  return _Scheduler_binding(function(callback) {
    v.stop();
  });
};

function _VirtualDom_makeCallback(eventNode, initialHandler)
{
  function callback(event)
  {
    var handler = callback.q;
    var result = _Json_runHelp(handler.a, arguments.length > 1 ? Array.from(arguments) : event);

    if (!$elm$core$Result$isOk(result))
    {
      return;
    }

    var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

    // 0 = Normal
    // 1 = MayStopPropagation
    // 2 = MayPreventDefault
    // 3 = Custom

    var value = result.a;
    var message = !tag ? value : tag < 3 ? value.a : value.message;
    var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
    var currentEventNode = (
      stopPropagation && event.stopPropagation(),
      (tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
      eventNode
    );
    var tagger;
    var i;
    while (tagger = currentEventNode.j)
    {
      if (typeof tagger == 'function')
      {
        message = tagger(message);
      }
      else
      {
        for (var i = tagger.length; i--; )
        {
          message = tagger[i](message);
        }
      }
      currentEventNode = currentEventNode.p;
    }
    currentEventNode(message, stopPropagation); // stopPropagation implies isSync
  }

  callback.q = initialHandler;

  return callback;
}

var $author$project$ReactNative$PanResponder$create = function (_v0) {
  return function(eventNode) {
    var props = {};
    for (; _v0.b; _v0 = _v0.b) { // WHILE_CONS
      const entry = _v0.a
      if (entry.$ === "a0") {
        if (entry.o && entry.o.a && entry.o.a.animatedEvent) {
          props[_VirtualDom_makeEventPropName(entry.n)] =
            Animated.event(
              entry.o.a.animatedEvent.mapping,
              {
                useNativeDriver: !!entry.o.a.animatedEvent.useNativeDrivder,
                listener: _VirtualDom_makeCallback(eventNode, entry.o)
              });
        } else {
          props[_VirtualDom_makeEventPropName(entry.n)] = _VirtualDom_makeCallback(
            eventNode,
            entry.o
          );
        }
      } else if (entry.$ === "a2") {
        props[entry.n] = entry.o;
      } 
    }

    return PanResponder.create(props);
  }
};
var $author$project$ReactNative$Animated$event = F2(
  function (_v0, _v1) {
    _v1.animatedEvent = {
      mapping: [_v0],
      options: {useNativeDrivder:false },
    };
    return _v1;
  });

var $author$project$ReactNative$Animated$event2 = F3(
  function (_v0, _v1, _v2) {
    _v2.animatedEvent = {
      mapping: [_v0 === _Utils_Tuple0 ? null : _v0, _v1],
      options: {useNativeDrivder:false },
    };
    return _v2;
  });

var $author$project$ReactNative$Animated$mapping = F2(
  function (fn, v) {
    if (fn.a === 2) {
      if (v instanceof Animated.Value) {
        return A2(fn, v, new Animated.Value(0)); 
      } else {
        return A2(fn, v.x, v.y);
      }
    } else {
      if (v instanceof Animated.Value) {
        fn(v);
      } else {
        fn(v.x);
      }
    }
  });

var $author$project$ReactNative$Animated$getLayout = function (v) {
  return v.getLayout();
};
var $author$project$ReactNative$PanResponder$onStartShouldSetPanResponder = function (d) {
  return A2(_VirtualDom_property, "onStartShouldSetPanResponder", function(event, gestureState) {
    return _Json_unwrap(A2(_Json_run, d, _Json_wrap([event, gestureState])));
  });
};


var $author$project$ReactNative$AppState$onChange = function (func) {
  return A3($elm$browser$Browser$Events$on,
    $elm$browser$Browser$Events$Document,
    'appStateChange',
    A2($elm$json$Json$Decode$map, func, $author$project$ReactNative$AppState$decoder));
};

var $author$project$ReactNative$Linking$canOpenURL = function (url) {
  return _Scheduler_binding(function(callback) {
    Linking.canOpenURL(url).then((supported) => callback(_Scheduler_succeed(supported)));
  });
};

var $author$project$ReactNative$Linking$openURL = function (url) {
  return _Scheduler_binding(function(callback) {
    Linking.openURL(url).then(() => callback(_Scheduler_succeed(_Utils_Tuple0)));
  });
};
var $author$project$ReactNative$Linking$openSettings = function () {
  return _Scheduler_binding(function(callback) {
    Linking.openSettings().then(() => callback(_Scheduler_succeed(_Utils_Tuple0)));
  });
}();

var $author$project$ReactNative$Linking$getInitialURL = function () {
  return _Scheduler_binding(function(callback) {
    Linking.getInitialURL().then((url) => callback(_Scheduler_succeed(url)));
  });
}();

var $author$project$ReactNative$Linking$sendIntent = F2(
  function (action, extras) {
    return _Scheduler_binding(function(callback) {
      console.log("extras", _Json_unwrap(extras));
      Linking.sendIntent(action, _Json_unwrap(extras)).then(() => callback(_Scheduler_succeed(_Utils_Tuple0)));
    });
  });

var $author$project$ReactNative$Appearance$onChange = function (tagger) {
  return A3($elm$browser$Browser$Events$on,
    $elm$browser$Browser$Events$Document,
    'appearanceChange',
    A2($elm$json$Json$Decode$map, tagger, $author$project$ReactNative$Appearance$colorSchemeDecoder));
};

var $author$project$ReactNative$Dimensions$onChange = function (decoder) {
  return A3($elm$browser$Browser$Events$on,
    $elm$browser$Browser$Events$Document,
    'dimensionChange',
    decoder);
};

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
  const WATCH_SETTING_PREFIX = "watchSetting_";

  return _Scheduler_spawn(_Scheduler_binding(function(callback)
  {
    function handler(event) { _Scheduler_rawSpawn(sendToSelf(event)); }
    let eventSubs;
    if (eventName === "appStateChange") {
      eventSubs = AppState.addEventListener("change", handler);
    } else if (eventName === "dimensionChange") {
      eventSubs = Dimensions.addEventListener("change", handler);
    } else if (/^keyboard(Will|Did)(Show|Hide|ChangeFrame)$/.test(eventName)) {
      eventSubs = Keyboard.addListener(eventName, handler);
    } else if (eventName === "appearanceChange") {
      eventSubs = Appearance.addChangeListener(handler);
    } else if (eventName === "hardwareBackPress") {
      // FIXME: return base on preventDefault (or stopPropagation?)
      eventSubs = BackHandler.addEventListener(eventName, (e) => { handler(e); return true; });
    } else if (eventName.startsWith(WATCH_SETTING_PREFIX)) {
      const watchId = Settings.watchKeys(eventName.substr(WATCH_SETTING_PREFIX.length), handler);
      eventSubs = { remove: () => Settings.clearWatch(watchId) };
    }
    return function() {
      if (eventSubs) eventSubs.remove();
    };
  }));
});

function _Browser_makeAnimator(model, draw)
{
  draw(model);
  return draw;
}
var $author$project$ReactNative$Animated$setValue = function (f) {
  return function(v) {
    v.setValue(f);
    return v;
  }
};

var $author$project$ReactNative$Easing$bezier = F2(
  function (p1, p2) {
    return Easing.bezier(p1.a, p1.b, p2.a, p2.b);
  });

var $author$project$ReactNative$Easing$elastic = function (n) {
  return Easing.elastic(n);
};

var $author$project$ReactNative$Easing$inOut = function (f) {
  return Easing.inOut(f);
};
var $author$project$ReactNative$Easing$in_ = function (f) {
  return Easing.in(f);
};
var $author$project$ReactNative$Easing$out = function (f) {
  return Easing.out(f);
};

var $author$project$ReactNative$Dimensions$get = function (dim) {
   return _Scheduler_binding(function(callback) {
     callback(_Scheduler_succeed(Dimensions.get(dim)));
   });
};

var $author$project$ReactNative$Appearance$getColorScheme = function () {
  return _Scheduler_binding(function(callback) {
    const result = _Json_runHelp($author$project$ReactNative$Appearance$colorSchemeDecoder, Appearance.getColorScheme())
    if (!$elm$core$Result$isOk(result)) {
      callback(_Scheduler_succeed($author$project$ReactNative$Appearance$NotIndicated));
      return;
    }

    callback(_Scheduler_succeed(result.a));
  });
}();

var $author$project$ReactNative$Keyboard$dismiss = function () {
   return _Scheduler_binding(function(callback) {
     const eventSubs = Keyboard.addListener("keyboardDidHide", () => {
      eventSubs.remove();
      callback(_Scheduler_succeed(_Utils_Tuple0));
     });
     Keyboard.dismiss();
   });
}();


var $author$project$ReactNative$Keyboard$on = F2(
  function (event, decoder) {
    return A3($elm$browser$Browser$Events$on,
      $elm$browser$Browser$Events$Document,
      event,
      decoder);
  });

var $author$project$ReactNative$Settings$watchKey = F2(
  function (key, decoder) {
    return A3($elm$browser$Browser$Events$on,
      $elm$browser$Browser$Events$Document,
      `watchSetting_${key}`,
      decoder);
  });

var $author$project$ReactNative$BackHandler$onHardwareBackPress = function (msg) {
  return A3($elm$browser$Browser$Events$on,
    $elm$browser$Browser$Events$Document,
    "hardwareBackPress",
    $elm$json$Json$Decode$succeed(msg));
};

var $author$project$ReactNative$Transforms$transform = function (trans) {
  return $author$project$ReactNative$Properties$style(
    {
      transform: _Json_unwrap(A2(
        $elm$json$Json$Encode$list,
        function (_v0) {
          var fs = _v0.a;
          return $elm$json$Json$Encode$object(fs);
        },
        trans))
    });
};

var $author$project$ReactNative$pressable = F2(
  function (props, children) {
    return A3($elm$html$Html$node, 'Pressable', props, _List_Cons(children, _List_Nil));
  });

var $author$project$ReactNative$PixelRatio$get = function (_v0) {
  return PixelRatio.get();
};
var $author$project$ReactNative$PixelRatio$getFontScale = function (_v0) {
  return PixelRatio.getFontScale();
};
var $author$project$ReactNative$PixelRatio$getPixelSizeForLayoutSize = function (layoutSize) {
  return PixelRatio.getPixelSizeForLayoutSize(layoutSize);
};
var $author$project$ReactNative$PixelRatio$roundToNearestPixel = function (layoutSize) {
  console.log("layoutSize", PixelRatio.roundToNearestPixel(layoutSize));
  return PixelRatio.roundToNearestPixel(layoutSize);
};
var $author$project$ReactNative$Platform$constants = function (decoder) {
  return A2($elm$json$Json$Decode$decodeValue, decoder, _Json_wrap(Platform.constants));
};
var $author$project$ReactNative$Platform$constants = function () {
  return JSON.stringify(Platform.constants);
}();

var $author$project$ReactNative$Share$share = F2(
  function (content, options) {
    return _Scheduler_binding(function(callback) {
      Share.share(content, options.a)
      .then((res) => {
        res.action = $author$project$ReactNative$Share$toAction(res.action);
        callback(_Scheduler_succeed(res));
      })
      .catch((err) => {
        callback(_Scheduler_fail(err.message));
      });
    });
  });

var $author$project$ReactNative$Share$share = function (props) {
  const content = {};
  const options = {};
  for ( ; props.b; props=props.b ) { // WHILE_CONS
    const p = props.a;
    const k = p.a;
    const v = _Json_unwrap(p.b);
    if (k === "message" || k === "title" || k === "url") {
      content[k] = v;
    } else {
      options[k] = v;
    }
  }

  return _Scheduler_binding(function(callback) {
    Share.share(content, options)
    .then((res) => {
      res.action = $author$project$ReactNative$Share$toAction(res.action);
      callback(_Scheduler_succeed(res));
    })
    .catch((err) => {
      callback(_Scheduler_fail(err.message));
    });
  });
};

var $author$project$ReactNative$Settings$get = F2(
  function (k, decoder) {
    return _Scheduler_binding(function(callback) {
      const result = _Json_runHelp(decoder, Settings.get(k));
      if ($elm$core$Result$isOk(result)) {
        callback(_Scheduler_succeed(result.a));
      } else {
        callback(_Scheduler_fail(result.a));
      }
    });
  });

var $author$project$ReactNative$Settings$set = function (settings) {
  return _Scheduler_binding(function(callback) {
    let res = undefined;
    for (; settings.b; settings = settings.b) {
      const p = settings.a;
      const k = p.a
      const v = _Json_unwrap(p.b);
      res = res || {};
      res[k] = v;
    }
    Settings.set(res);
    callback(_Scheduler_fail(_Utils_Tuple0));
  });
};
