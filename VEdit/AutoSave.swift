//
//  AutoSave.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/29.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Foundation
import RxSwift

class AutoSave {
  let minIdleSecs = 3.0
  
  var rx_timer = PublishSubject<Void>()

  func startTimer() {
    Timer.scheduledTimer(timeInterval: minIdleSecs, target: self, selector: #selector(self.interval), userInfo: nil, repeats: true)
  }
  
  @objc func interval(_: Timer) {
    rx_timer.on(.next(()))
  }
}
