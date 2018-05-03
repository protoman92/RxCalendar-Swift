//
//  RegularCalendarViewController.swift
//  RxCalendarDemo
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarPreset
import RxCalendarPresetLogic
import UIKit

public final class RegularCalendarViewController: UIViewController {
  @IBOutlet fileprivate weak var regularCalendar: RxRegularCalendar!

  override public func viewDidLoad() {
    super.viewDidLoad()
    let decorator = AppDecorator()
    let model = RxCalendarPreset.RegularCalendar.Model(Singleton.instance)
    let viewModel = RxCalendarPreset.RegularCalendar.ViewModel(model)
    regularCalendar.dependency = (viewModel, decorator)
  }
}
