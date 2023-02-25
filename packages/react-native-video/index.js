import React from "react";
import Video from "react-native-video";
import { GestureDetector, Gesture } from "react-native-gesture-handler";

const VideoPlayer = ({ seekTime, ...props }) => {
  // console.log('VideoPlayer props: ', props);
  const ref = React.useRef(null);

  React.useEffect(() => {
    if (typeof seekTime === "number" && ref.current) {
      // when uri changes, it seems that we need wait some time otherwise the seeking operation is not work
      // FIXME: check if there is event callback when uri changes
      const timer = setTimeout(() => {
        if (ref.current) {
          ref.current.seek(seekTime / 1000);
        }
      }, 50);
      return () => {
        clearTimeout(timer);
      };
    }
  }, [props.source.uri, seekTime]);

  const ph = Gesture.Pinch().onStart((e) => {
    onPinch && onPinch(e.scale);
  });

  return <Video ref={ref} {...props} />;
};

export default (tag) => {
  if (tag === "Video") return VideoPlayer;
};
