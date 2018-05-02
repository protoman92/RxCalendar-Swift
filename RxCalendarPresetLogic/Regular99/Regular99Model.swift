//
//  Regular99Model.swift
//  calendar99-presetLogic
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarLogic
import RxSwift
import SwiftFP

/// Dependency for Regular99 preset model.
public protocol RxRegular99CalendarModelDependency:
  RxMonthHeaderModelDependency,
  RxMonthSectionModelDependency,
  RxSelectWeekdayModelDependency {}

/// Model for Regular99 preset.
public protocol RxRegular99CalendarModelType:
  RxMonthHeaderModelType,
  RxMonthSectionModelType,
  RxSelectWeekdayModelType {}

// MARK: - Model.
public extension RxCalendarPreset.Regular99 {

  /// Model implementation for Regular99 preset.
  public final class Model {
    fileprivate let monthHeaderModel: RxMonthHeaderModelType
    fileprivate let monthSectionModel: RxMonthSectionModelType
    fileprivate let selectableWdModel: RxSelectWeekdayModelType

    required public init(_ monthHeaderModel: RxMonthHeaderModelType,
                         _ monthSectionModel: RxMonthSectionModelType,
                         _ selectableWdModel: RxSelectWeekdayModelType) {
      self.monthHeaderModel = monthHeaderModel
      self.monthSectionModel = monthSectionModel
      self.selectableWdModel = selectableWdModel
    }

    convenience public init(_ dependency: RxRegular99CalendarModelDependency) {
      let monthHeaderModel = RxCalendarLogic.MonthHeader.Model(dependency)
      let monthSectionModel = RxCalendarLogic.MonthSection.Model(dependency)
      let selectableWdModel = RxCalendarLogic.SelectWeekday.Model(dependency)
      self.init(monthHeaderModel, monthSectionModel, selectableWdModel)
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarPreset.Regular99.Model: RxGridDisplayFunction {
  public var weekdayStacks: Int {
    return monthSectionModel.weekdayStacks
  }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarPreset.Regular99.Model: RxMonthAwareModelFunction {
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return monthSectionModel.currentMonthStream
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarPreset.Regular99.Model: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return monthSectionModel.currentMonthReceiver
  }
}

// MARK: - RxMonthControlModelFunction
extension RxCalendarPreset.Regular99.Model: RxMonthControlModelFunction {
  public var initialMonthStream: PrimitiveSequence<SingleTrait, RxCalendarLogic.Month> {
    return monthSectionModel.initialMonthStream
  }

  public var minimumMonth: RxCalendarLogic.Month {
    return monthSectionModel.minimumMonth
  }

  public var maximumMonth: RxCalendarLogic.Month {
    return monthSectionModel.maximumMonth
  }
}

// MARK: - RxSelectHighlightFunction
extension RxCalendarPreset.Regular99.Model: RxSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return monthSectionModel.highlightPart(date)
  }
}

// MARK: - RxMonthHeaderModelFunction
extension RxCalendarPreset.Regular99.Model: RxMonthHeaderModelFunction {
  public func formatMonthDescription(_ month: RxCalendarLogic.Month) -> String {
    return monthHeaderModel.formatMonthDescription(month)
  }
}

// MARK: - RxMultiDaySelectionFunction
extension RxCalendarPreset.Regular99.Model: RxMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return monthSectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return monthSectionModel.allSelectionStream
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarPreset.Regular99.Model: RxSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return monthSectionModel.isDateSelected(date)
  }
}

// MARK: - RxMultiMonthGridSelectionCalculator
extension RxCalendarPreset.Regular99.Model: RxMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [RxCalendarLogic.MonthComp],
                                   _ currentMonth: RxCalendarLogic.Month,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return monthSectionModel
      .gridSelectionChanges(monthComps, currentMonth, prev, current)
  }
}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarPreset.Regular99.Model: RxWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return monthSectionModel.firstWeekday
  }
}

// MARK: - RxWeekdayDisplayModelFunction
extension RxCalendarPreset.Regular99.Model: RxWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return selectableWdModel.weekdayDescription(weekday)
  }
}

// MARK: - RxMonthSectionModelDependency
extension RxCalendarPreset.Regular99.Model: RxMonthSectionModelDependency {
  public func dayFromFirstDate(_ month: RxCalendarLogic.Month,
                               _ firstDateOffset: Int) -> RxCalendarLogic.Day? {
    return monthSectionModel.dayFromFirstDate(month, firstDateOffset)
  }
}

// MARK: - RxRegular99CalendarModelType
extension RxCalendarPreset.Regular99.Model: RxRegular99CalendarModelType {}
