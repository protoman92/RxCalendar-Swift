//
//  MonthViewDecorator.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarLogic
import UIKit

/// Decorator for month display view.
public protocol RxMonthViewDecoratorType {

  /// Background color for month view.
  var monthViewBackgroundColor: UIColor { get }

  /// Get a date cell decorator.
  ///
  /// - Parameters:
  ///   - indexPath: An IndexPath instance.
  ///   - item: A Day instance.
  /// - Returns: A RxDateCellDecoratorType instance.
  func dateCellDecorator(_ indexPath: IndexPath, _ item: RxCalendarLogic.Day)
    -> RxDateCellDecoratorType
}

