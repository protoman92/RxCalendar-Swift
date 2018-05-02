//
//  WeekdayDisplayModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the weekday model and its dependency.
public protocol RxWeekdayDisplayModelFunction: RxWeekdayAwareModelFunction {
  
  /// Get the description for a weekday.
  ///
  /// - Parameter weekday: An Int value.
  /// - Returns: A String value.
  func weekdayDescription(_ weekday: Int) -> String
}

/// Dependency for weekday model.
public protocol RxWeekdayDisplayModelDependency:
  RxWeekdayAwareModelDependency,
  RxWeekdayDisplayModelFunction {}

/// Model for weekday display view.
public protocol RxWeekdayDisplayModelType:
  RxWeekdayAwareModelType,
  RxWeekdayDisplayModelFunction {}

// MARK: - Model.
public extension RxCalendarLogic.WeekdayDisplay {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: RxWeekdayDisplayModelDependency

    required public init(_ dependency: RxWeekdayDisplayModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarLogic.WeekdayDisplay.Model: RxWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}

// MARK: - RxWeekdayDisplayModelFunction
extension RxCalendarLogic.WeekdayDisplay.Model: RxWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return dependency.weekdayDescription(weekday)
  }
}

// MARK: - RxWeekdayDisplayModelType
extension RxCalendarLogic.WeekdayDisplay.Model: RxWeekdayDisplayModelType {}
