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
  TouchableWithoutFeedback,
  View,
  VirtualizedList,
  DrawerLayoutAndroid,
  TouchableNativeFeedback,
  InputAccessoryView,
  SafeAreaView,
} from "react-native";

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
};

const EventNodeContext = React.createContext();
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

const ElmNodeComponent = (props) => {
  const eventNode = React.useContext(EventNodeContext);
  const actualProps = _VirtualDom_factsToReactProps(props, eventNode);
  const Component = scope.resolveComponent(props.tag);

  const children = listToElementArray(props.kidList);
  if (children.length === 0) {
    return <Component {...actualProps} />;
  } else if (children.length === 1) {
    return <Component {...actualProps}>{children[0]}</Component>;
  }

  return <Component {...actualProps}>{children}</Component>;
};

const ElmThunkComponent = (props) => {
  return React.useMemo(() => props.thunk(), props.refs);
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
  React.useLayoutEffect(() => {
    const elmApp = scope.Elm[props.entry || "Main"].init({
      flags: props.flags,
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
      <EventNodeContext.Provider value={sendToAppRef.current}>
        {listToElementArray(doc.body)}
      </EventNodeContext.Provider>
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
          props.style = Object.assign(props.style, _Json_unwrap(value));
        } else {
          props.style = v;
        }
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
