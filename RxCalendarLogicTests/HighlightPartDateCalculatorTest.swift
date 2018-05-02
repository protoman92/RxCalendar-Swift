//
//  HighlightPartDateCalculatorTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import RxCalendarLogic

public final class HighlightPartDateCalculatorTest: RootTest {
  fileprivate var dateCalc: RxCalendarLogic.DateCalc.HighlightPart!
  fileprivate var weekdayStacks: Int!

  fileprivate var gridPositions: Set<RxCalendarLogic.GridPosition> {
    return Set((0..<10).flatMap({monthIndex in
      (0..<iterations!).map({RxCalendarLogic.GridPosition(monthIndex, $0)})
    }))
  }

  override public func setUp() {
    super.setUp()
    weekdayStacks = 6
    dateCalc = RxCalendarLogic.DateCalc.HighlightPart(self, self, weekdayStacks!)
  }
}

public extension HighlightPartDateCalculatorTest {
  public func test_calculateGridSelectionChanges_shouldWork(
    _ calculatedPos: Set<RxCalendarLogic.GridPosition>,
    _ totalDayCount: Int)
  {
    /// Setup
    let actualGridPositions = gridPositions

    /// When & Then
    XCTAssertTrue(calculatedPos.all({$0.dayIndex >= 0 && $0.dayIndex < totalDayCount}))

    for gridSelection in actualGridPositions {
      let prevSelection = gridSelection.decrementingDayIndex()
      let nextSelection = gridSelection.incrementingDayIndex()

      if gridSelection.dayIndex >= 0 && gridSelection.dayIndex < totalDayCount {
        XCTAssertTrue(calculatedPos.contains(gridSelection))
      }

      if prevSelection.dayIndex >= 0 && gridSelection.dayIndex < totalDayCount {
        XCTAssertTrue(calculatedPos.contains(prevSelection))
      }

      if nextSelection.dayIndex < totalDayCount {
        XCTAssertTrue(calculatedPos.contains(nextSelection))
      }
    }
  }

  public func test_calculateMultiMonthGridSelectionChanges_shouldWork() {
    let totalDayCount = weekdayStacks! * RxCalendarLogic.Util.weekdayCount
    let currentMonth = RxCalendarLogic.Month(Date())
    let newGridPositions = dateCalc.gridSelectionChanges([], currentMonth, [], [])
    test_calculateGridSelectionChanges_shouldWork(newGridPositions, totalDayCount)
  }

  public func test_calculateSingleMonthGridSelectionChanges_shouldWork() {
    let totalDayCount = 1000
    let currentMonth = RxCalendarLogic.Month(Date())
    let currentMonthComp = RxCalendarLogic.MonthComp(currentMonth, totalDayCount, 1)
    let newGridPositions = dateCalc.gridSelectionChanges(currentMonthComp, [], [])
    test_calculateGridSelectionChanges_shouldWork(newGridPositions, totalDayCount)
  }
}

extension HighlightPartDateCalculatorTest: RxMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [RxCalendarLogic.MonthComp],
                                   _ currentMonth: RxCalendarLogic.Month,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return gridPositions
  }
}

extension HighlightPartDateCalculatorTest: RxSingleMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComp: RxCalendarLogic.MonthComp,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return gridPositions
  }
}
