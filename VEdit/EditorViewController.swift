//
//  ViewController.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/24.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Cocoa
import RxSwift

class EditorViewController: NSViewController, NSWindowDelegate {
  @IBOutlet var textView: TextView!
  var isModified = true
  let autoSave = AutoSave()

  var fileUrl: URL?

  fileprivate let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    textView.setLayoutOrientation(NSLayoutManager.TextLayoutOrientation.vertical)
    textView.font = NSFont(name: "Hiragino Mincho ProN", size: 15.0)

    self.view.wantsLayer = true
    self.view.layer?.backgroundColor = NSColor.gray.cgColor

    AppDelegate.preference.paddingVert.asObservable().subscribe(onNext: { (paddingVert: Int) in
      self.textView.textContainerInset = NSSize(width: Double(paddingVert), height: Double(AppDelegate.preference.paddingHoriz.value))
    }).disposed(by: disposeBag)

    AppDelegate.preference.paddingHoriz.asObservable().subscribe(onNext: { (paddingHoriz: Int) in
      self.textView.textContainerInset = NSSize(width: Double(AppDelegate.preference.paddingVert.value) , height: Double(paddingHoriz))
    }).disposed(by: disposeBag)

    textView.rx_command.subscribe(onNext: { (command) in
      self.doCommand(command: command)
    }).disposed(by: disposeBag)
    
    textView.rx_textDidChange.subscribe(onNext: { (_) in
      self.isModified = true
    }).disposed(by: disposeBag)
    
    autoSave.rx_timer.subscribe(onNext: { (_) in
      self.saveOverwite()
    }).disposed(by: disposeBag)
    
    autoSave.startTimer()
    
  }

  override func viewDidAppear() {
    updateWindowTitle()

    if let w = self.view.window {
      w.delegate = self
    }
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  func doCommand(command: Command) {
    switch command {
    case .moveUp: textView.moveUp(nil)
    case .moveDown: textView.moveDown(nil)
    case .moveForward: textView.moveForward(nil)
    case .moveBackward: textView.moveBackward(nil)
    }
  }
  
  func open() {
    guard let window = self.view.window else {
      return
    }
  
    let openPanel = NSOpenPanel()
    openPanel.allowedFileTypes = ["txt"]

    openPanel.beginSheetModal(for: window) { (modalResponse) in
      switch modalResponse {
      case .OK:
        guard let url = openPanel.url else { return }
        do {
          let s = try String(contentsOf: url, encoding: String.Encoding.utf8)
          self.textView.string = s
          self.fileUrl = url
          self.updateWindowTitle()
        } catch let error as NSError {
          print("failed to save file \(error)")
        }
      default:
        window.close()
      }
    }
  }
  
  func save() {
    if fileUrl != nil {
      saveOverwite()
    } else {
      saveNew()
    }
  }

  func saveNew() {
    guard let window = self.view.window else {
       print("save new error")
      return
    }

    let savePanel = NSSavePanel()
    savePanel.directoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop)")    // デフォルトで表示されるフォルダ
    savePanel.allowedFileTypes = ["txt"]

    savePanel.beginSheetModal(for: window) { (modalResponse) in
      switch modalResponse {
      case .OK:
        guard let url = savePanel.url else { return }

        self.fileUrl = url
        self.updateWindowTitle()
        self.saveOverwite()
      default:
        print("Canceled")
      }
    }
  }
  
  func saveOverwite() {
    guard let fileUrl = fileUrl else { return }
    
    if !isModified {
      return
    }

    do {
      try self.saveToFile(file: fileUrl)
      isModified = false
    } catch let error as NSError {
      print("failed to save file \(error)")
    }
  }
  
  private func saveToFile(file: URL) throws {
    try textView.string.write(to: file, atomically: true, encoding: String.Encoding.utf8)
  }
  
  private func updateWindowTitle() {
    guard let window = self.view.window else { return }

    if let url = fileUrl {
      window.title = url.lastPathComponent
    } else {
      window.title = "Untitled"
    }
  }

  // MARK: - NSWindowDelegate
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    
    if fileUrl == nil && !textView.string.isEmpty {
      let a = NSAlert()
      a.messageText = "Do you want to save the changes made to the document?"
      a.addButton(withTitle: "Save")
      a.addButton(withTitle: "Cancel")
      a.addButton(withTitle: "Close")
      a.alertStyle = .warning
      let r = a.runModal()
      switch r {
      case .alertFirstButtonReturn:
        save()
      case .alertSecondButtonReturn:
        return false
      case .alertThirdButtonReturn:
        return true
      default:
        break
      }
    }

    return true
  }
}

