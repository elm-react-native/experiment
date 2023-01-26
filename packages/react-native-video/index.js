import React from "react";
import Video from "react-native-video";

const VideoPlayer = (props) => {
  // console.log('VideoPlayer props: ', props);
  const ref = React.useRef(null);

  React.useEffect(() => {
    if (props.seekTime) {
      ref.current.seek(props.seekTime / 1000);
    }
  }, [props.source.uri, props.seekTime]);

  return <Video ref={ref} {...props} />;
};

export default (tag) => {
  if (tag === "Video") return VideoPlayer;
};
