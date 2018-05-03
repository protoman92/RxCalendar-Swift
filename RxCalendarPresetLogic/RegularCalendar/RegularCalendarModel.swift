//
//  RegularCalendarModel.swift
//  RxCalendarPresetLogic
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Dependency for RegularCalendar preset model.
public protocol RxRegularCalendarModelDependency:
  RxMonthHeaderModelDependency,
  RxMonthSectionModelDependency,
  RxSelectWeekdayModelDependency {}

/// Model for RegularCalendar preset.
public protocol RxRegularCalendarModelType:
  RxMonthHeaderModelType,
  RxMonthSectionModelType,
  RxSelectWeekdayModelType {}

// MARK: - Model.
public extension RxCalendarPreset.RegularCalendar {

  /// Model implementation for RegularCalendar preset.
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

    convenience public init(_ dependency: RxRegularCalendarModelDependency) {
      let monthHeaderModel = RxCalendarLogic.MonthHeader.Model(dependency)
      let monthSectionModel = RxCalendarLogic.MonthSection.Model(dependency)
      let selectableWdModel = RxCalendarLogic.SelectWeekday.Model(dependency)
      self.init(monthHeaderModel, monthSectionModel, selectableWdModel)
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarPreset.RegularCalendar.Model: RxGridDisplayFunction {
  public var weekdayStacks: Int {
    return monthSectionModel.weekdayStacks
  }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarPreset.RegularCalendar.Model: RxMonthAwareModelFunction {
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return monthSectionModel.currentMonthStream
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarPreset.RegularCalendar.Model: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return monthSectionModel.currentMonthReceiver
  }
}

// MARK: - RxMonthControlModelFunction
extension RxCalendarPreset.RegularCalendar.Model: RxMonthControlModelFunction {
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
extension RxCalendarPreset.RegularCalendar.Model: RxSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return monthSectionModel.highlightPart(date)
  }
}

// MARK: - RxMonthHeaderModelFunction
extension RxCalendarPreset.RegularCalendar.Model: RxMonthHeaderModelFunction {
  public func formatMonthDescription(_ month: RxCalendarLogic.Month) -> String {
    return monthHeaderModel.formatMonthDescription(month)
  }
}

// MARK: - RxMultiDaySelectionFunction
extension RxCalendarPreset.RegularCalendar.Model: RxMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return monthSectionModel.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return monthSectionModel.allSelectionStream
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarPreset.RegularCalendar.Model: RxSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return monthSectionModel.isDateSelected(date)
  }
}

// MARK: - RxMultiMonthGridSelectionCalculator
extension RxCalendarPreset.RegularCalendar.Model: RxMultiMonthGridSelectionCalculator {
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
extension RxCalendarPreset.RegularCalendar.Model: RxWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return monthSectionModel.firstWeekday
  }
}

// MARK: - RxWeekdayDisplayModelFunction
extension RxCalendarPreset.RegularCalendar.Model: RxWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return selectableWdModel.weekdayDescription(weekday)
  }
}

// MARK: - RxMonthSectionModelDependency
extension RxCalendarPreset.RegularCalendar.Model: RxMonthSectionModelDependency {
  public func dayFromFirstDate(_ month: RxCalendarLogic.Month,
                               _ firstDateOffset: Int) -> RxCalendarLogic.Day? {
    return monthSectionModel.dayFromFirstDate(month, firstDateOffset)
  }
}

// MARK: - RxRegularCalendarModelType
extension RxCalendarPreset.RegularCalendar.Model: RxRegularCalendarModelType {}
