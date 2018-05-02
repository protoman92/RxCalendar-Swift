//
//  MonthHeaderDecorator.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Decorator for month header view.
public protocol RxMonthHeaderDecoratorType {

  /// Tint color for navigation buttons.
  var navigationButtonTintColor: UIColor { get }

  /// Tint color for navigation buttons, for when the user has reached min/max.
  var navigationButtonDisabledTintColor: UIColor { get }

  /// Text color for month description label.
  var monthDescriptionTextColor: UIColor { get }

  /// Font for month description label.
  var monthDescriptionFont: UIFont { get }
}
