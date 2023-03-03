//
//  VideoViewManager.swift
//  Plex
//
//  Created by Roy on 2023/3/2.
//

import Foundation
import React
import MobileVLCKit

@objc (VideoViewManager)
class VideViewManager : RCTViewManager {
  override static func requiresMainQueueSetup() -> Bool {
    return true;
  };

  override func view() -> UIView! {
    return VideoView(eventDispatcher: bridge.eventDispatcher() as? RCTEventDispatcher)
  }
}

class VideoView : UIView, VLCMediaPlayerDelegate {
  var _player: VLCMediaPlayer!;
  
  var _paused: Bool = true;
  var _pausedDirty: Bool = false;
  
  var _seek: Float = 0;
  var _seekDirty: Bool = false;
  
  var _rate: Float = 1.0;
  var _rateDirty: Bool = false;
  
  var _src: String = "";
  
  private var _eventDispatcher:RCTEventDispatcher?
  @objc var onProgress: RCTDirectEventBlock?
  @objc var onOpening: RCTDirectEventBlock?
  @objc var onPlaying: RCTDirectEventBlock?
  @objc var onBuffering: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onEnded: RCTDirectEventBlock?
  
  init(eventDispatcher:RCTEventDispatcher!) {
    super.init(frame: CGRect.zero)
    
    _eventDispatcher = eventDispatcher
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func mediaPlayerStateChanged(_ aNotification: Notification) {
    if _player == nil { return }
    
    let state = _player.state;
    switch (state) {
    case .opening:
      self.onOpening?(["target": reactTag ?? ""]);
      break;
    case .buffering:
      self.onBuffering?(["target": reactTag ?? ""]);
      break;
    case .error:
      self.onError?(["target": reactTag ?? ""]);
      break;
    case .ended:
      self.onEnded?(["target": reactTag ?? ""]);
      break;
    case .stopped:
      // Not sure this is correct: the player state changed to stopped when remainingTime is more than one second indicate there is some error
      if _player.remainingTime != nil && _player.remainingTime!.intValue > 1000 {
        self.onError?(["target": reactTag ?? ""]);
      }
      break;
    case .playing:
      self.onPlaying?(["target": reactTag ?? ""]);
      break;
    case .paused:
      // ??
      break;
    case .esAdded:
      // ??
      break;
    default:
      break;
    }
  }
  
  func mediaPlayerTimeChanged(_ aNotification: Notification) {
    if _player != nil {
      self.onProgress?([
        "target": reactTag ?? "",
        "currentTime": NSNumber(value: _player.time.intValue),
      ]);
    }
  }
  
  func applyProps() {
    if (_player == nil) { return }
        
    if (_pausedDirty) {
      _pausedDirty = false
      
      if (_paused) {
        _player.pause()
      } else {
        _player.play()
      }
    }
    
    if (_seekDirty) {
      _seekDirty = false
      
      _player.position = _seek
    }
    
    if (_rateDirty) {
      _rateDirty = false
      _player.rate = _rate
    }
  }
  
  @objc
  func setSrc(_ src: String?) {
    if _src == src { return }
    
    _src = src ?? ""
    _pausedDirty = true
    
    releasePlayer()
    
    if _src != "" {
      _player = VLCMediaPlayer()
      _player.delegate = self
      _player.drawable = self
      _player.media = VLCMedia(url: URL(string: _src)!)
    }
    
    DispatchQueue.main.async {[weak self] in
      self?.applyProps()
    }
  }
  
  @objc
  func setPaused(_ paused: Bool) {
    if _paused == paused { return }
    
    _paused = paused;
    _pausedDirty = true;
    
    DispatchQueue.main.async {[weak self] in
      self?.applyProps()
    }
  }
  
  @objc
  func setSeek(_ seek: Float) {
    if _seek == seek { return }
    
    _seek = seek;
    _seekDirty = true;
    
    DispatchQueue.main.async {[weak self] in
      self?.applyProps()
    }
  }
  
  @objc
  func setRate(_ rate: Float) {
    if _rate == rate { return }
    _rate = rate
    _rateDirty = true;
    
    DispatchQueue.main.async {[weak self] in
      self?.applyProps()
    }
  }
  
  func releasePlayer() {
    _player?.delegate = nil
    _player?.drawable = nil
    _player?.pause()
    _player?.stop()
    _player = nil
  }
  
  
  override func removeFromSuperview() {
    super.removeFromSuperview()
    releasePlayer()
  }
}

