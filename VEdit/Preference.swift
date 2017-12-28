//
//  Preference.swift
//  VEdit
//
//  Created by 堀泰祐 on 2017/12/28.
//  Copyright © 2017 taisukeh. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class Preference: Codable {
  let paddingVert = BehaviorRelay<Int>(value: 0)
  let paddingHoriz = BehaviorRelay<Int>(value: 0)
  let disposeBag = DisposeBag()
  
  enum CodingKeys: String, CodingKey {
    case paddingVert
    case paddingHoriz
  }
  
  init() {
    initRx()
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    paddingVert.accept(try values.decode(Int.self, forKey: .paddingVert))
    paddingHoriz.accept(try values.decode(Int.self, forKey: .paddingHoriz))
    
    initRx()
  }
  
  func initRx() {
    paddingVert.asObservable().subscribe(onNext: { (_) in self.save() }).disposed(by: disposeBag)
    paddingHoriz.asObservable().subscribe(onNext: { (_) in self.save() }).disposed(by: disposeBag)
  }
  
  func encode(to encoder: Encoder) throws {
    // containerはvarにしておく
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(paddingVert.value, forKey: .paddingVert)
    try container.encode(paddingHoriz.value, forKey: .paddingHoriz)
  }
  
  class var fileUrl: URL {
    let path = NSHomeDirectory() + "/preference.json"
    return URL(fileURLWithPath: path)
  }
  
  class func load() -> Preference {
    do {
      let data = try Data(contentsOf: fileUrl)
      return try JSONDecoder().decode(Preference.self, from: data)
    } catch let error as NSError {
      print("failed to load file \(error)")
      return Preference()
    }
  }

  func save() {
    let jsonData = try! JSONEncoder().encode(self)
    let jsonString = String(data: jsonData, encoding: .utf8)
    
    do {
      try jsonString?.write(to: Preference.fileUrl, atomically: false, encoding: .utf8)
    } catch let error as NSError {
      print("failed to save file \(error)")
    }
  }
}
