//
//  TextView.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/29.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class TextView: NSTextView, NSTextViewDelegate {
  
  let rx_command = PublishSubject<Command>()
  let rx_textDidChange = PublishSubject<Void>()

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
    self.delegate = self
  }
  
  override func keyDown(with event: NSEvent) {
    if self.hasMarkedText() {
      super.keyDown(with: event)
      return
    }
    
    var key = Key()
    
    key.ctrl = event.modifierFlags.contains(NSEvent.ModifierFlags.control)
    key.command = event.modifierFlags.contains(NSEvent.ModifierFlags.command)
    key.option = event.modifierFlags.contains(NSEvent.ModifierFlags.option)
    if let s = keycodeTable[event.keyCode] {
      key.s = s
    }
    if let command = AppDelegate.keymap.findCommand(key: key) {
      rx_command.on(.next(command))
      return
    }
    
    if let context = NSTextInputContext.current {
      context.handleEvent(event)
    }
  }
  
  func textDidChange(_ notification: Notification) {
    rx_textDidChange.on(.next(()))
  }
}
