//
//  ViewController.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/24.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Cocoa
import RxSwift

class EditorViewController: NSViewController {
  @IBOutlet var textView: NSTextView!

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
  }
  
  override func viewDidAppear() {
    updateWindowTitle()
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
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
        do {
          try self.saveToFile(file: url)
          self.fileUrl = url
          self.updateWindowTitle()
        } catch let error as NSError {
          print("failed to save file \(error)")
        }
      default:
        print("Canceled")
      }
    }
  }
  
  func saveOverwite() {
    guard let fileUrl = fileUrl else { return }

    do {
      try self.saveToFile(file: fileUrl)
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
}

