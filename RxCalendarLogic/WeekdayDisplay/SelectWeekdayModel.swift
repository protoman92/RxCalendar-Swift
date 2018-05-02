//
//  SelecteekdayModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol RxSelectWeekdayModelFunction:
  RxMonthAwareModelFunction,
  RxMultiDaySelectionFunction {}

/// Dependency for selectable weekday display.
public protocol RxSelectWeekdayModelDependency:
  RxSelectWeekdayModelFunction,
  RxWeekdayDisplayModelDependency {}

/// Model for selectable weekday display.
public protocol RxSelectWeekdayModelType:
  RxSelectWeekdayModelFunction,
  RxWeekdayDisplayModelType {}

// MARK: - Model.
public extension RxCalendarLogic.SelectWeekday {

  /// Model implementation.
  public final class Model {
    fileprivate let weekdayModel: RxWeekdayDisplayModelType
    fileprivate let dependency: RxSelectWeekdayModelDependency

    required public init(_ weekdayModel: RxWeekdayDisplayModelType,
                         _ dependency: RxSelectWeekdayModelDependency) {
      self.weekdayModel = weekdayModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: RxSelectWeekdayModelDependency) {
      let weekdayModel = RxCalendarLogic.WeekdayDisplay.Model(dependency)
      self.init(weekdayModel, dependency)
    }
  }
}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarLogic.SelectWeekday.Model: RxWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return weekdayModel.firstWeekday
  }
}

// MARK: - RxWeekdayDisplayModelFunction
extension RxCalendarLogic.SelectWeekday.Model: RxWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return weekdayModel.weekdayDescription(weekday)
  }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarLogic.SelectWeekday.Model: RxMonthAwareModelFunction {
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return dependency.currentMonthStream
  }
}

// MARK: - RxMultiDaySelectionFunction
extension RxCalendarLogic.SelectWeekday.Model: RxMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return dependency.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return dependency.allSelectionStream
  }
}

// MARK: - RxSelectableWeekdayModelType
extension RxCalendarLogic.SelectWeekday.Model: RxSelectWeekdayModelType {}
