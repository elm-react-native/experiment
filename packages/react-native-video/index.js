import React from "react";
import Video from "react-native-video";
import { GestureDetector, Gesture } from "react-native-gesture-handler";

const VideoPlayer = ({ seekTime, onPinch, ...props }) => {
  // console.log('VideoPlayer props: ', props);
  const ref = React.useRef(null);

  React.useEffect(() => {
    if (typeof seekTime === "number") {
      ref.current.seek(seekTime / 1000);
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
