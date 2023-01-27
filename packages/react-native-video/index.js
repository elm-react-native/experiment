import React from "react";
import Video from "react-native-video";

const VideoPlayer = ({ seekTime, ...props }) => {
  // console.log('VideoPlayer props: ', props);
  const ref = React.useRef(null);

  React.useEffect(() => {
    if (seekTime) {
      ref.current.seek(seekTime / 1000);
    }
  }, [props.source.uri, seekTime]);

  return <Video ref={ref} {...props} />;
};

export default (tag) => {
  if (tag === "Video") return VideoPlayer;
};
