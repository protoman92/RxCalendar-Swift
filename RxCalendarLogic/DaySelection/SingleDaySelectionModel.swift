//
//  SingleDaySelectionModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol RxSingleDaySelectionModelFunction:
  RxMultiDaySelectionFunction,
  RxSingleDaySelectionFunction {}

/// Dependency for single day selection model.
public protocol RxSingleDaySelectionModelDependency:
  RxSingleDaySelectionModelFunction,
  RxWeekdayAwareModelDependency {}

/// Day selection model.
public protocol RxSingleDaySelectionModelType:
  RxSingleDaySelectionModelFunction,
  RxWeekdayAwareModelType {}

// MARK: - Model.
public extension RxCalendarLogic.DaySelect {

  /// Model implementation for day selection views.
  public final class Model {
    fileprivate let dependency: RxSingleDaySelectionModelDependency

    required public init(_ dependency: RxSingleDaySelectionModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - RxMultiDaySelectionFunction
extension RxCalendarLogic.DaySelect.Model: RxMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return dependency.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return dependency.allSelectionStream
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarLogic.DaySelect.Model: RxSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - RxSingleDaySelectionModelType
extension RxCalendarLogic.DaySelect.Model: RxSingleDaySelectionModelType {}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarLogic.DaySelect.Model: RxWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}
