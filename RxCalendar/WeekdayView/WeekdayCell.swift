//
//  WeekdayCell.swift
//  RxCalendar
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarLogic
import UIKit

/// Default weekday cell.
public final class RxWeekdayCell: UICollectionViewCell {
  @IBOutlet fileprivate weak var weekdayLbl: UILabel!

  public func setupWithWeekday(_ decorator: RxWeekdayCellDecoratorType,
                               _ weekday: RxCalendarLogic.Weekday) {
    guard let weekdayLbl = self.weekdayLbl else { return }
    weekdayLbl.text = weekday.description
    weekdayLbl.textColor = decorator.weekdayDescriptionTextColor
    weekdayLbl.font = decorator.weekdayDescriptionFont
  }
}
