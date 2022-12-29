/* eslint-disable */
import React from "react";
import {
  ActivityIndicator,
  Button,
  FlatList,
  Image,
  ImageBackground,
  KeyboardAvoidingView,
  Modal,
  Pressable,
  RefreshControl,
  ScrollView,
  SectionList,
  StatusBar,
  Switch,
  Text,
  TextInput,
  TouchableHighlight,
  TouchableOpacity,
  StyleSheet,
  TouchableWithoutFeedback,
  View,
  VirtualizedList,
  DrawerLayoutAndroid,
  TouchableNativeFeedback,
  InputAccessoryView,
  SafeAreaView,
  Alert,
  Vibration,
  Platform,
  PlatformColor,
  Animated,
  Easing,
  PanResponder,
  AppState,
} from "react-native";
import {
  NavigationContainer,
  createNavigationContainerRef,
  StackActions,
} from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

const navigationRef = createNavigationContainerRef();
const Stack = createNativeStackNavigator();
const allComponents = {
  ActivityIndicator,
  Button,
  FlatList,
  Image,
  ImageBackground,
  KeyboardAvoidingView,
  Modal,
  Pressable,
  RefreshControl,
  ScrollView,
  SectionList,
  StatusBar,
  Switch,
  Text,
  TextInput,
  TouchableHighlight,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
  VirtualizedList,
  DrawerLayoutAndroid,
  TouchableNativeFeedback,
  InputAccessoryView,
  SafeAreaView,
  "Stack.Navigator": Stack.Navigator,
  "Animated.View": Animated.View,
};

const EventNodeContext = React.createContext();
const ModelContext = React.createContext();
let scope = {};

const ElmMapComponent = (props) => {
  const eventNode = React.useContext(EventNodeContext);
  return (
    <EventNodeContext.Provider value={{ j: props.tagger, p: eventNode }}>
      {props.node}
    </EventNodeContext.Provider>
  );
};

const ElmKeyedNodeComponent = (props) => {
  const eventNode = React.useContext(EventNodeContext);
  const actualProps = _VirtualDom_factsToReactProps(props.factList, eventNode);
  const children = _List_toArray(props.kidList).map((kid, i) => (
    <React.Fragment key={kid.a}>{kid.b}</React.Fragment>
  ));
  const Component = scope.resolveComponent(props.tag);
  return <Component {...actualProps}>{children}</Component>;
};

const listToElementArray = (list) => {
  if (!list) return [];

  const items = _List_toArray(list);
  return items.length > 1
    ? items.map((item, i) => <React.Fragment key={i}>{item}</React.Fragment>)
    : items;
};

const listToChildren = (list) => {
  const children = listToElementArray(list);
  if (children.length === 0) return null;
  if (children.length === 1) return children[0];
  else return children;
};

const ElmNodeComponent = (props) => {
  const eventNode = React.useContext(EventNodeContext);
  const actualProps = _VirtualDom_factsToReactProps(props, eventNode);
  const Component = scope.resolveComponent(props.tag);

  const children = listToChildren(props.kidList);
  return <Component {...actualProps}>{children}</Component>;
};

const SectionListComponent = (props) => {
  const eventNode = React.useContext(EventNodeContext);
  const actualProps = _VirtualDom_factsToReactProps(props, eventNode);
  if (actualProps.sections) {
    const { sections, ...rest } = actualProps;
    const sections2 = _List_toArray(sections).map((sec) => ({
      ...sec,
      data: _List_toArray(sec.data),
    }));
    return <SectionList {...rest} sections={sections2}></SectionList>;
  }

  return <SectionList {...actualProps}></SectionList>;
};

const screenListenersMakeCallback = (listeners, eventNode) => {
  // WHILE_CONS
  for (var ls = listeners, result = {}; ls.b; ls = ls.b) {
    const entry = ls.a;
    if (entry.$ === "a0") {
      result[entry.n] = _VirtualDom_makeCallback(eventNode, entry.o);
    }
  }
  return result;
};

const createScreenElement = (props, screenComponentsCache, eventNode, key) => {
  const { component, ...actualProps } = _VirtualDom_factsToReactProps(
    props,
    null
  );
  if (actualProps.listeners) {
    actualProps.listeners = screenListenersMakeCallback(
      actualProps.listeners,
      eventNode
    );
  }

  let screenComponent = screenComponentsCache.get(component);
  if (!screenComponent) {
    screenComponent = (props) => {
      const model = React.useContext(ModelContext);
      return component(model, props.route.params);
    };
    screenComponentsCache.set(component, screenComponent);
  }

  return (
    <Stack.Screen {...actualProps} component={screenComponent} key={key} />
  );
};

const NavigatorComponent = (props) => {
  const eventNode = React.useContext(EventNodeContext);
  const actualProps = _VirtualDom_factsToReactProps(props, eventNode);
  if (actualProps.screenListeners) {
    actualProps.screenListeners = screenListenersMakeCallback(
      actualProps.screenListeners,
      eventNode
    );
  }

  const Component = scope.resolveComponent(props.tag);
  const screenComponentsCacheRef = React.useRef(new Map());

  let screens = [];
  for (let kids = props.kidList; kids.b; kids = kids.b) {
    const ps = kids.a;
    screens.push(
      createScreenElement(
        ps,
        screenComponentsCacheRef.current,
        eventNode,
        screens.length
      )
    );
  }
  return <Component {...actualProps}>{screens}</Component>;
};

const ElmThunkComponent = (props) => {
  return React.useMemo(() => props.thunk(), props.refs);
};

const getEntryName = () => {
  for (var k in scope.Elm) {
    if (scope.Elm.hasOwnProperty(k)) {
      var v = scope.Elm[k];
      if (typeof v === "object" && typeof v.init === "function") {
        return k;
      }
    }
  }
  return null;
};

const ElmRoot = (props) => {
  const [model, setModel] = React.useState(null);
  const viewRef = React.useRef(null);
  const sendToAppRef = React.useRef(null);
  const titleRef = React.useRef(null);
  React.useMemo(() => {
    scope.resolveComponent = (name) => {
      const Component = allComponents[name];
      if (Component) return Component;
      else if (props.resolveComponent) return props.resolveComponent(name);
      else return name;
    };
  }, [props.resolveComponent]);
  React.useEffect(() => {
    const elmApp = scope.Elm[getEntryName()].init({
      flags: props.flags,
      navigation: navigationRef,
      onInit(initialModel, view, sendToApp, title) {
        viewRef.current = view;
        sendToAppRef.current = sendToApp;
        titleRef.current = title || _VirtualDom_doc.title;
        setModel(initialModel);
      },
      onModelChanged: setModel,
    });
  }, []);

  if (
    viewRef.current === null ||
    model === null ||
    sendToAppRef.current === null
  ) {
    return null;
  }

  const ele = viewRef.current(model);
  if (React.isValidElement(ele)) {
    return (
      <EventNodeContext.Provider value={sendToAppRef.current}>
        {ele}
      </EventNodeContext.Provider>
    );
  } else {
    const doc = ele;
    titleRef.current !== doc.title &&
      (_VirtualDom_doc.title = titleRef.current = doc.title);
    return (
      <NavigationContainer ref={navigationRef}>
        <EventNodeContext.Provider value={sendToAppRef.current}>
          <ModelContext.Provider value={model}>
            {listToChildren(doc.body)}
          </ModelContext.Provider>
        </EventNodeContext.Provider>
      </NavigationContainer>
    );
  }
};

function _VirtualDom_makeEventPropName(name) {
  return "on" + name.charAt(0).toUpperCase() + name.slice(1);
}

function _Json_unwrap_nested(value) {
  const a = value.a;
  if (typeof a === "object") {
    for (var k in a) {
      if (a.hasOwnProperty(k)) {
        if (typeof a[k].$ !== "undefined") {
          a[k] = _Json_unwrap_nested(a[k]);
        }
      }
    }
  }
  return a;
}

const ELM_NODE_COMPONENT_PROP_SET = { tag: 1, factList: 1, kidList: 1 };
function _VirtualDom_factsToReactProps(inputProps, eventNode) {
  var factList = inputProps.factList;
  var initPanResponder;

  for (
    var props = {};
    factList.b;
    factList = factList.b // WHILE_CONS
  ) {
    var entry = factList.a;

    var tag = entry.$;

    var key = entry.n;
    var value = entry.o;

    if (tag === "a0") {
      props[_VirtualDom_makeEventPropName(key)] = _VirtualDom_makeCallback(
        eventNode,
        value
      );
    }

    if (tag === "a1") {
      var style = props.style || (props.style = {});
      style[key] = value;

      continue;
    }

    if (tag === "a2") {
      if (key === "className") {
        _VirtualDom_addClass(props, key, _Json_unwrap(value));
      } else if (key === "style") {
        const v = _Json_unwrap(value);
        if (typeof v === "function") {
          props.style = (...args) => {
            return _List_toArray(v(...args)).map(_Json_unwrap_nested);
          };
        } else if (props.style) {
          props.style = StyleSheet.compose(props.style, _Json_unwrap(value));
        } else {
          props.style = v;
        }
      } else if (key === "__panResponder") {
        const v = _Json_unwrap(value);
        initPanResponder = v(eventNode);
      } else if (key === "refreshControl") {
        const v = _Json_unwrap(value);
        props[key] = (
          <RefreshControl {..._VirtualDom_factsToReactProps(v, eventNode)} />
        );
      } else {
        const v = _Json_unwrap(value);
        if (typeof v === "function" && typeof v.f === "function") {
          props[key] = v.f;
        } else {
          props[key] = v;
        }
      }
      continue;
    }
  }

  if (eventNode) {
    const panResponder = React.useRef(initPanResponder).current;
    if (panResponder) props = Object.assign(props, panResponder.panHandlers);
  }

  // Components like TouchableWithoutFeedback works by cloning its child and applying responder props to it.
  // It is therefore required that any intermediary components pass through those props to the underlying React Native component.
  for (let k in inputProps) {
    if (
      inputProps.hasOwnProperty(k) &&
      !ELM_NODE_COMPONENT_PROP_SET[k] &&
      !props[k]
    ) {
      props[k] = inputProps[k];
    }
  }

  return props;
}
