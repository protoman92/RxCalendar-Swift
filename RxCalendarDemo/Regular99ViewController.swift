//
//  Regular99ViewController.swift
//  RxCalendarDemo
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarPreset
import RxCalendarPresetLogic
import UIKit

public final class Regular99ViewController: UIViewController {
  @IBOutlet fileprivate weak var regular99Calendar: RxRegular99Calendar!

  override public func viewDidLoad() {
    super.viewDidLoad()
    let decorator = AppDecorator()
    let model = RxCalendarPreset.Regular99.Model(Singleton.instance)
    let viewModel = RxCalendarPreset.Regular99.ViewModel(model)
    regular99Calendar.dependency = (viewModel, decorator)
  }
}
