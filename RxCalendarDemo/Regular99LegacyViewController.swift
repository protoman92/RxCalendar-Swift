//
//  Regular99LegacyViewController.swift
//  RxCalendarDemo
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarLegacy
import RxCalendarLogic
import RxCalendarPreset
import UIKit

public final class Regular99LegacyViewController: UIViewController {
  @IBOutlet fileprivate weak var regular99Calendar: RxRegular99Calendar!

  deinit {
    print("DEINIT \(self)")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    let decorator = AppDecorator()
    regular99Calendar!.legacyDependencyLevel2 = (self, decorator)
  }
}

// MARK: - RxRegular99CalendarNoDefaultDelegate
extension Regular99LegacyViewController: RxRegular99CalendarNoDefaultDelegate {
  public func minimumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
    return RxCalendarLogic.Month(4, 2018)
  }

  public func maximumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
    return RxCalendarLogic.Month(10, 2018)
  }

  public func initialMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
    return RxCalendarLogic.Month(6, 2018)
  }

  public func regular99(_ calendar: RxRegular99Calendar,
                        currentMonthChanged month: RxCalendarLogic.Month) {
    print("Current month:", month)
  }

  public func regular99(_ calendar: RxRegular99Calendar,
                        selectionChanged selections: Set<RxCalendarLogic.Selection>) {
    print("Current selection:", selections)
  }
}
