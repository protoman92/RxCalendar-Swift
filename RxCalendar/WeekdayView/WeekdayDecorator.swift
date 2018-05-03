//
//  WeekdayDecorator.swift
//  RxCalendar
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Decorator for weekday view.
public protocol RxWeekdayViewDecoratorType {

  /// Background color for weekday view.
  var weekdayViewBackground: UIColor { get }

  /// Get a weekday cell decorator.
  ///
  /// - Parameters:
  ///   - indexPath: An IndexPath instance.
  ///   - item: A Weekday instance.
  /// - Returns: A RxWeekdayCellDecoratorType instance.
  func weekdayCellDecorator(_ indexPath: IndexPath, _ item: RxCalendarLogic.Weekday)
    -> RxWeekdayCellDecoratorType
}

/// Decorator for weekday cell view.
public protocol RxWeekdayCellDecoratorType {

  /// Text color for weekday description label.
  var weekdayDescriptionTextColor: UIColor { get }

  /// Font for weekday description label.
  var weekdayDescriptionFont: UIFont { get }
}
