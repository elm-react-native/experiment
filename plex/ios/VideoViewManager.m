//
//  RNIContextMenuButtonManager.m
//  IosContextMenuExample
//
//  Created by Dominic Go on 10/28/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <React/RCTBridge.h>
#import <React/RCTViewManager.h>
 

@interface RCT_EXTERN_MODULE(VideoViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(src, NSString);
RCT_EXPORT_VIEW_PROPERTY(seek, float);
RCT_EXPORT_VIEW_PROPERTY(rate, float);
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL);
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString);
RCT_EXPORT_VIEW_PROPERTY(onOpening, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaying, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onProgress, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBuffering, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onEnded, RCTDirectEventBlock);

@end
