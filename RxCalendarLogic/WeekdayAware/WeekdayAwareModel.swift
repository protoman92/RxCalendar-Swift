//
//  WeekdayAwareModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and its dependency.
public protocol RxWeekdayAwareModelFunction {

  /// Get the first day of a week (e.g. Monday).
  var firstWeekday: Int { get }
}

/// Dependency for weekday-aware model.
public protocol RxWeekdayAwareModelDependency: RxWeekdayAwareModelFunction {}

/// Model for weekday-aware views.
public protocol RxWeekdayAwareModelType: RxWeekdayAwareModelFunction {}
