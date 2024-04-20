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
  var _srcDirty: Bool = false;
  
  var _resizeMode: String = "contain";
  var _resizeModeDirty: Bool = false;
  
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
      if _player.remainingTime != nil && _player.remainingTime!.intValue > 1000 {
        self.onError?(["target": reactTag ?? ""]);
        break;
      }
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
    if (_srcDirty) {
      _srcDirty = false;
      
      if _src != "" {
        releasePlayer()
      
        _player = VLCMediaPlayer()
        _player.delegate = self
        _player.drawable = self
        _player.media = VLCMedia(url: URL(string: _src)!)
      }
    }

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
    
    if (_resizeModeDirty) {
      _resizeModeDirty = false
      
      if (_resizeMode == "contain") {
        UIView.animate(withDuration: 0.3, animations: {
          [weak self] in
          self?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
      } else if (_resizeMode == "cover") {
        UIView.animate(withDuration: 0.3, animations: {
          [weak self] in
          self?.transform = CGAffineTransform(scaleX: 1.23, y: 1.23)
        })
      }
    }
    
//    "19:9".withCString { str in
//      _player.videoAspectRatio = UnsafeMutablePointer<CChar>(mutating: str)
//    }
  }
  
  @objc
  func setSrc(_ src: String?) {
    if _src == src { return }
    
    _src = src ?? ""
    _srcDirty = true;
    _pausedDirty = true;
    _rateDirty = true;
    _seekDirty = true;
    _resizeModeDirty = true;

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
  
  @objc
  func setResizeMode(_ resizeMode: String) {
    if _resizeMode == resizeMode { return }
    _resizeMode = resizeMode
    _resizeModeDirty = true;
    
    DispatchQueue.main.async {[weak self] in
      self?.applyProps()
    }
  }
  
  func releasePlayer() {
    _player?.delegate = nil
    _player?.drawable = nil
    _player?.pause()
    _player?.stop()
    _player?.media = nil
    _player = nil
  }
  
  
  override func removeFromSuperview() {
    super.removeFromSuperview()
    releasePlayer()
  }
  
  func videoSize() -> CGSize {
    let media = _player.media;
    if let width = media?.metaDictionary[VLCMediaTracksInformationVideoWidth] as? NSNumber,
       let height = media?.metaDictionary[VLCMediaTracksInformationVideoHeight] as? NSNumber {
        return CGSize(width: width.doubleValue, height: height.doubleValue)
    } else {
        return _player.videoSize
    }
  }
}

