//
//  KeyMap.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/29.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Foundation

struct Key: Equatable {
  static func ==(l: Key, r: Key) -> Bool {
    return l.ctrl == r.ctrl && l.option == r.option && l.command == r.command && l.s == r.s;
  }
  
  var ctrl: Bool = false
  var option: Bool = false
  var command: Bool = false
  
  var s = ""
}

enum Command: String {
  case moveForward
  case moveBackward
  case moveUp
  case moveDown
}

class KeyMap {
  var map: [(Key, Command)] = []
  
  init() {
    map.append((Key(ctrl: true, option: false, command: false, s: "n"), .moveForward))
    map.append((Key(ctrl: true, option: false, command: false, s: "p"), .moveBackward))
    map.append((Key(ctrl: true, option: false, command: false, s: "f"), .moveUp))
    map.append((Key(ctrl: true, option: false, command: false, s: "b"), .moveDown))
  }
  
  func findCommand(key: Key) -> Command? {
    for (k, c) in map {
      if key == k {
        return c
      }
    }
    
    return nil
  }
}
