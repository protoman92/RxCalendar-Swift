//
//  SelectionTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 19/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import RxCalendarLogic

/// Tests for selection object.
public final class SelectionTest: RootTest {}

public extension SelectionTest {
  public func test_defaultSelection_shouldWorkd() {
    /// Setup
    let selection1 = RxCalendarLogic.Selection()
    let selection2 = RxCalendarLogic.Selection()

    /// When & Then
    XCTAssertEqual(selection1, selection2)
    XCTAssertEqual(selection1.hashValue, selection2.hashValue)

    XCTAssertEqual(selection1.contains(Date.random()!),
                   selection2.contains(Date.random()!))

    XCTAssertEqual(selection1.gridPosition([], 0),
                   selection2.gridPosition([], 0))
  }
  
  public func test_dateSelection_shouldWork() {
    /// Setup
    let firstWeekday = firstWeekdayForTest!
    
    /// When
    for _ in 0..<iterations! {
      let shouldEqual = Bool.random()
      let date1, date2: Date
      
      if shouldEqual {
        date1 = Date.random()!
        date2 = date1
      } else {
        date1 = Date.random()!
        date2 = Date.random()!.addingTimeInterval(24 * 60 * 60)
      }
      
      let s1 = RxCalendarLogic.DateSelection(date1, firstWeekday)
      let s2 = RxCalendarLogic.DateSelection(date2, firstWeekday)
      
      /// Then
      XCTAssertEqual(s1 == s2, shouldEqual)
      XCTAssertTrue(s1.contains(date1))
      XCTAssertTrue(s2.contains(date2))
      XCTAssertEqual(s1.description == s2.description, shouldEqual)
    }
  }

  public func test_repeatWeekdaySelection_shouldWork() {
    /// Setup
    let calendar = Calendar.current

    /// When
    for firstWeekday in 1...7 {
      for _ in 0..<iterations! {
        let month = RxCalendarLogic.Month(Date.random()!)

        let monthComps = (0..<100)
          .map({month.with(monthOffset: $0)!})
          .map({RxCalendarLogic.MonthComp($0, 42, firstWeekday)})

        for weekday in 1...6 {
          let weekday1 = weekday
          let weekday2 = weekday + 1
          let s1 = RxCalendarLogic.RepeatWeekdaySelection(weekday1, firstWeekday)
          let s2 = RxCalendarLogic.RepeatWeekdaySelection(weekday2, firstWeekday)
          let date1 = RxCalendarLogic.Util.firstDateWithWeekday(month, weekday1)!
          let date2 = RxCalendarLogic.Util.firstDateWithWeekday(month, weekday2)!
          let position1 = s1.gridPosition(monthComps, 0)
          let position2 = s2.gridPosition(monthComps, 0)

          /// Then
          XCTAssertNotEqual(s1, s2)
          XCTAssertTrue(s1.contains(date1))
          XCTAssertFalse(s2.contains(date1))
          XCTAssertTrue(s2.contains(date2))
          XCTAssertFalse(s1.contains(date2))

          for p1 in position1 {
            let monthComp = monthComps[p1.monthIndex]
            let p1Date = monthComp.dateAtIndex(p1.dayIndex)!
            XCTAssertEqual(calendar.component(.weekday, from: p1Date), weekday1)
          }

          for p2 in position2 {
            let monthComp = monthComps[p2.monthIndex]
            let p2Date = monthComp.dateAtIndex(p2.dayIndex)!
            XCTAssertEqual(calendar.component(.weekday, from: p2Date), weekday2)
          }

          XCTAssertTrue(s1.gridPosition(monthComps, -1).isEmpty)
          XCTAssertTrue(s1.gridPosition(monthComps, monthComps.count + 1).isEmpty)
          XCTAssertNotEqual(s1.description, s2.description)
        }
      }
    }
  }
}
