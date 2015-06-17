//
//  SoundPlayer.swift
//  Invisible
//
//  Created by thomas on 6/13/15.
//  Copyright (c) 2015 thomas. All rights reserved.
//

import UIKit
import AudioToolbox

public class SoundPlayer: NSObject {
  
  var filename : String?
  
  private struct Internal {
    static var cache = [NSURL:SystemSoundID]()
  }
  
  public enum Sound: String {
    case Alert = "ringring.wav"
    case Send = "chord.wav"
  }
  
  public func playSound(sound: Sound) {
    if let url = NSBundle.mainBundle().URLForResource(sound.rawValue, withExtension: nil) {
      var soundID: SystemSoundID = Internal.cache[url] ?? 0
      if soundID == 0 {
        AudioServicesCreateSystemSoundID(url, &soundID)
        Internal.cache[url] = soundID
      }
      AudioServicesPlaySystemSound(soundID)
    } else {
      println("Could not find sound file name `\(sound.rawValue)`")
    }
  }

}
