//
//  PreferenceViewController.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/28.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class PreferenceViewController: NSViewController, NSTextFieldDelegate {
  @IBOutlet weak var paddingVertTextField: NSTextField!
  @IBOutlet weak var paddingHorizTextField: NSTextField!
  
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.

    paddingVertTextField.delegate = self
    paddingHorizTextField.delegate = self
    
    AppDelegate.preference.paddingVert.asObservable().subscribe(onNext: { (paddingVert) in
      self.paddingVertTextField.stringValue = String(paddingVert)
    }).disposed(by: disposeBag)

    AppDelegate.preference.paddingHoriz.asObservable().subscribe(onNext: { (paddingHoriz) in
      self.paddingHorizTextField.stringValue = String(paddingHoriz)
    }).disposed(by: disposeBag)
  }
  
  
  // MARK: - NSTextFieldDelegate
  
  override func controlTextDidChange(_ obj: Notification) {
    guard let sender = obj.object as? NSTextField else { return }

    if sender === paddingVertTextField {
      if let v = Int(paddingVertTextField.stringValue) {
        AppDelegate.instance.preference.paddingVert.accept(v)
      }
    }
    if sender === paddingHorizTextField {
      if let v = Int(paddingHorizTextField.stringValue) {
        AppDelegate.instance.preference.paddingHoriz.accept(v)
      }
    }
  }
}
