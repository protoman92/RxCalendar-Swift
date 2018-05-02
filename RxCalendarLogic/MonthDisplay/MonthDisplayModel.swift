//
//  MonthDisplayModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol RxMonthDisplayModelFunction:
  RxSelectHighlightFunction,
  RxSingleMonthGridSelectionCalculator {}

/// Dependency for month display model.
public protocol RxMonthDisplayModelDependency:
  RxMonthControlModelDependency,
  RxMonthDisplayModelFunction,
  RxMonthGridModelDependency,
  RxSingleDaySelectionModelDependency {}

/// Model for month display view.
public protocol RxMonthDisplayModelType:
  RxMonthControlModelType,
  RxMonthDisplayModelFunction,
  RxMonthGridModelType,
  RxSingleDaySelectionModelType
{
  /// Calculate the Day range for a Month.
  ///
  /// - Parameters month: A Month instance.
  /// - Returns: An Array of Day.
  func dayRange(_ month: RxCalendarLogic.Month) -> [RxCalendarLogic.Day]
}

public extension RxCalendarLogic.MonthDisplay {

  /// Month display model implementation.
  public final class Model {
    fileprivate let monthControlModel: RxMonthControlModelType
    fileprivate let monthGridModel: RxMonthGridModelType
    fileprivate let daySelectionModel: RxSingleDaySelectionModelType
    fileprivate let dependency: RxMonthDisplayModelDependency

    required public init(_ monthControlModel: RxMonthControlModelType,
                         _ monthGridModel: RxMonthGridModelType,
                         _ daySelectionModel: RxSingleDaySelectionModelType,
                         _ dependency: RxMonthDisplayModelDependency) {
      self.monthControlModel = monthControlModel
      self.monthGridModel = monthGridModel
      self.daySelectionModel = daySelectionModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: RxMonthDisplayModelDependency) {
      let monthControlModel = RxCalendarLogic.MonthControl.Model(dependency)
      let monthGridModel = RxCalendarLogic.MonthGrid.Model(dependency)
      let daySelectionModel = RxCalendarLogic.DaySelect.Model(dependency)
      self.init(monthControlModel, monthGridModel, daySelectionModel, dependency)
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLogic.MonthDisplay.Model: RxGridDisplayFunction {
  public var weekdayStacks: Int { return monthGridModel.weekdayStacks }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarLogic.MonthDisplay.Model: RxMonthAwareModelFunction {
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return dependency.currentMonthStream
  }
}

// MARK: - RxMonthControlModelType
extension RxCalendarLogic.MonthDisplay.Model: RxMonthControlModelType {
  public var initialMonthStream: Single<RxCalendarLogic.Month> {
    return monthControlModel.initialMonthStream
  }

  public var minimumMonth: RxCalendarLogic.Month {
    return monthControlModel.minimumMonth
  }

  public var maximumMonth: RxCalendarLogic.Month {
    return monthControlModel.maximumMonth
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthDisplay.Model: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return dependency.currentMonthReceiver
  }
}

// MARK: - RxSelectHighlightFunction
extension RxCalendarLogic.MonthDisplay.Model: RxSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return dependency.highlightPart(date)
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarLogic.MonthDisplay.Model: RxSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - RxMultiDaySelectionFunction
extension RxCalendarLogic.MonthDisplay.Model: RxMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return daySelectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return daySelectionModel.allSelectionStream
  }
}

// MARK: - RxSingleMonthGridSelectionCalculator
extension RxCalendarLogic.MonthDisplay.Model: RxSingleMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComp: RxCalendarLogic.MonthComp,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return dependency.gridSelectionChanges(monthComp, prev, current)
  }
}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarLogic.MonthDisplay.Model: RxWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return daySelectionModel.firstWeekday
  }
}

// MARK: - RxMonthDisplayModelType
extension RxCalendarLogic.MonthDisplay.Model: RxMonthDisplayModelType {
  public func dayRange(_ month: RxCalendarLogic.Month) -> [RxCalendarLogic.Day] {
    let calendar = Calendar.current

    return RxCalendarLogic.Util.dateRange(month, firstWeekday, weekdayStacks).map({
      let description = calendar.component(.day, from: $0).description

      return RxCalendarLogic.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }
}
