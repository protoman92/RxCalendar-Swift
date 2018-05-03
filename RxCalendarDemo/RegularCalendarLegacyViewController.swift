//
//  RegularCalendarLegacyViewController.swift
//  RxCalendarDemo
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarLegacy
import RxCalendarLogic
import RxCalendarPreset
import UIKit

public final class RegularCalendarLegacyViewController: UIViewController {
  @IBOutlet fileprivate weak var regularCalendar: RxRegularCalendar!

  deinit {
    print("DEINIT \(self)")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    let decorator = AppDecorator()
    regularCalendar!.legacyDependencyLevel2 = (self, decorator)
  }
}

// MARK: - RxRegularCalendarNoDefaultDelegate
extension RegularCalendarLegacyViewController: RxRegularCalendarNoDefaultDelegate {
  public func minimumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
    return RxCalendarLogic.Month(4, 2018)
  }

  public func maximumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
    return RxCalendarLogic.Month(10, 2018)
  }

  public func initialMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
    return RxCalendarLogic.Month(6, 2018)
  }

  public func regularCalendar(_ calendar: RxRegularCalendar,
                              currentMonthChanged month: RxCalendarLogic.Month) {
    print("Current month:", month)
  }

  public func regularCalendar(_ calendar: RxRegularCalendar,
                              selectionChanged selections: Set<RxCalendarLogic.Selection>) {
    print("Current selection:", selections)
  }
}
