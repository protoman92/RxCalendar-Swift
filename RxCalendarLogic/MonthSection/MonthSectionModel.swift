//
//  MonthSectionModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol RxMonthSectionModelFunction:
  RxMultiMonthGridSelectionCalculator,
  RxSelectHighlightFunction {}

/// Dependency for month section model.
public protocol RxMonthSectionModelDependency:
  RxMonthControlModelDependency,
  RxMonthGridModelDependency,
  RxMonthSectionModelFunction,
  RxSingleDaySelectionModelDependency {}

/// Model for month section view.
public protocol RxMonthSectionModelType:
  RxMonthControlModelType,
  RxMonthGridModelType,
  RxMonthSectionModelFunction,
  RxSingleDaySelectionModelType
{
  /// Calculate the day for a month and a first date offset (i.e. how distant
  /// the day is from the first date in the grid).
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func dayFromFirstDate(_ month: RxCalendarLogic.Month,
                        _ firstDateOffset: Int) -> RxCalendarLogic.Day?
}

public extension RxCalendarLogic.MonthSection {

  /// Model implementation for month section view.
  public final class Model {
    fileprivate let monthControlModel: RxMonthControlModelType
    fileprivate let monthGridModel: RxMonthGridModelType
    fileprivate let daySelectionModel: RxSingleDaySelectionModelType
    fileprivate let dependency: RxMonthSectionModelDependency

    required public init(_ monthControlModel: RxMonthControlModelType,
                         _ monthGridModel: RxMonthGridModelType,
                         _ daySelectionModel: RxSingleDaySelectionModelType,
                         _ dependency: RxMonthSectionModelDependency) {
      self.monthControlModel = monthControlModel
      self.monthGridModel = monthGridModel
      self.daySelectionModel = daySelectionModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: RxMonthSectionModelDependency) {
      let monthControlModel = RxCalendarLogic.MonthControl.Model(dependency)
      let monthGridModel = RxCalendarLogic.MonthGrid.Model(dependency)
      let daySelectionModel = RxCalendarLogic.DaySelect.Model(dependency)
      self.init(monthControlModel, monthGridModel, daySelectionModel, dependency)
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLogic.MonthSection.Model: RxGridDisplayFunction {
  public var weekdayStacks: Int { return monthGridModel.weekdayStacks }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarLogic.MonthSection.Model: RxMonthAwareModelFunction {
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthSection.Model: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - RxMonthControlModelFunction
extension RxCalendarLogic.MonthSection.Model: RxMonthControlModelFunction {
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

// MARK: - RxGridSelectionCalculatorType
extension RxCalendarLogic.MonthSection.Model: RxMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [RxCalendarLogic.MonthComp],
                                   _ currentMonth: RxCalendarLogic.Month,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return dependency.gridSelectionChanges(monthComps, currentMonth, prev, current)
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarLogic.MonthSection.Model: RxSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - RxSelectHighlightFunction
extension RxCalendarLogic.MonthSection.Model: RxSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return dependency.highlightPart(date)
  }
}

// MARK: - RxDaySelectionModelType
extension RxCalendarLogic.MonthSection.Model: RxSingleDaySelectionModelType {
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return daySelectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return daySelectionModel.allSelectionStream
  }
}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarLogic.MonthSection.Model: RxWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return daySelectionModel.firstWeekday
  }
}

// MARK: - RxMonthSectionModelType
extension RxCalendarLogic.MonthSection.Model: RxMonthSectionModelType {
  public func dayFromFirstDate(_ month: RxCalendarLogic.Month,
                               _ firstDateOffset: Int) -> RxCalendarLogic.Day? {
    return RxCalendarLogic.Util.dateWithOffset(month, firstWeekday, firstDateOffset).map({
      let description = Calendar.current.component(.day, from: $0).description

      return RxCalendarLogic.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }
}
