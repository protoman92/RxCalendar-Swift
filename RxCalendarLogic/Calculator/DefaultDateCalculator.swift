//
//  DefaultDateCalculator.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

public extension RxCalendarLogic.DateCalc {

  /// Default date calculator.
  public final class Default {
    public let weekdayStacks: Int
    public let firstWeekday: Int
    fileprivate let calendar: Calendar

    public init(_ weekdayStacks: Int, _ firstWeekday: Int) {
      self.weekdayStacks = weekdayStacks
      self.firstWeekday = firstWeekday
      calendar = Calendar.current
    }
  }
}

// MARK: - RxMultiMonthGridSelectionCalculator
extension RxCalendarLogic.DateCalc.Default: RxMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [RxCalendarLogic.MonthComp],
                                   _ currentMonth: RxCalendarLogic.Month,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return monthComps.index(where: {$0.month == currentMonth})
      .map({monthIndex in Set(extractChanges(prev, current)
        .flatMap({$0.gridPosition(monthComps, monthIndex)}))})
      .getOrElse([])
  }
}

// MARK: - RxSingleMonthGridSelectionCalculatorType
extension RxCalendarLogic.DateCalc.Default: RxSingleMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComp: RxCalendarLogic.MonthComp,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return Set(extractChanges(prev, current)
      .flatMap({self.gridPosition(monthComp, $0)}))
  }

  /// We need to include the previous and next month components here as well,
  /// and call the pre-specified method that deals with Month Array. We also
  /// assume that the day count remains the same for all Months.
  fileprivate func gridPosition(_ monthComp: RxCalendarLogic.MonthComp,
                                _ selection: RxCalendarLogic.Selection)
    -> Set<RxCalendarLogic.GridPosition>
  {
    var monthComps = [RxCalendarLogic.MonthComp]()

    monthComp.month.with(monthOffset: -1)
      .map({monthComp.with(month: $0)})
      .map({monthComps.append($0)})

    monthComps.append(monthComp)

    monthComp.month.with(monthOffset: 1)
      .map({monthComp.with(month: $0)})
      .map({monthComps.append($0)})

    return selection.gridPosition(monthComps, 1)
  }
}
