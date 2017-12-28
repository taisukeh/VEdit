//
//  AppDelegate.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/24.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var preferenceWinController: NSWindowController?
  
  let preference = Preference.load()
  lazy var mainStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)

  
  class var instance: AppDelegate {
    return NSApplication.shared.delegate as! AppDelegate
  }
  
  class var preference: Preference {
    return instance.preference
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  // MARK: - Storyboard
  
  // MARK: - Menu

  @IBAction func preferenceSelected(_ sender: NSMenuItem) {
    
    if let w = preferenceWinController {
      w.showWindow(nil)
      return
    }
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preference"), bundle: nil)

    if let c = storyboard.instantiateInitialController() as? NSWindowController {
      c.showWindow(nil)
      preferenceWinController = c
    }
  }
  
  @IBAction func openSelected(_ sender: Any) {
    guard let w = mainStoryboard.instantiateInitialController() as? NSWindowController else { return }
    guard let vc = w.contentViewController as? EditorViewController else { return }
    
    w.window?.makeKeyAndOrderFront(nil)

    vc.open()
  }

  @IBAction func saveSelected(_ sender: Any) {
    guard let kw = NSApplication.shared.keyWindow else { return }
    
    guard let vc = kw.contentViewController as? EditorViewController else { return }
    
    vc.save()
  }
  
}



