import React from "react";
import Video from "react-native-video";

const VideoPlayer = (props) => {
  // console.log('VideoPlayer props: ', props);
  const ref = React.useRef(null);

  React.useEffect(() => {
    if (props.seekOnStart) {
      ref.current.seek(props.seekOnStart / 1000);
    }
  }, [props.source.uri]);

  return <Video ref={ref} {...props} />;
};

export default (tag) => {
  if (tag === "Video") return VideoPlayer;
};
