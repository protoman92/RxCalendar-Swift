//
//  MonthTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import RxCalendarLogic

/// Tests for months.
public final class MonthTest: RootTest {
  override public func setUp() {
    super.setUp()

    // Since these tests do not require any waiting, might as well be ludicrous
    // with the iteration count.
    iterations = 20000
  }

  public func test_newMonthWithMonthOffset_shouldWork() {
    /// Setup
    var date = Date()
    var month = RxCalendarLogic.Month(date)

    /// When
    for _ in 0..<iterations! {
      let newMonth = month.with(monthOffset: 1)!
      let dateComponents = newMonth.dateComponents()
      let newDate = Calendar.current.date(from: dateComponents)!
      let oldDate = date
      date = newDate
      month = newMonth

      /// Then
      XCTAssertGreaterThan(newDate, oldDate)
    }
  }

  public func test_checkContainDate_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    let date = Date()
    let firstMonth = RxCalendarLogic.Month(date)

    /// When
    for i in 0..<iterations! {
      let newMonth = firstMonth.with(monthOffset: i)!
      let dateOffset = Int.random(0, 40)
      let newDate = calendar.date(byAdding: .day, value: dateOffset, to: date)!

      /// Then
      let newMonthForDate = RxCalendarLogic.Month(newDate)
      XCTAssertEqual(newMonth == newMonthForDate, newMonth.contains(newDate))
    }
  }

  public func test_getDatesWithWeekday_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    let firstMonth = RxCalendarLogic.Month(Date())

    /// When
    for i in 0..<iterations! {
      let month = firstMonth.with(monthOffset: i)!

      for weekday in 1...7 {
        let dates = month.datesWithWeekday(weekday)

        /// Then
        for date in dates {
          let weekdayComp = calendar.component(.weekday, from: date)
          XCTAssertEqual(weekdayComp, weekday)
          XCTAssertEqual(RxCalendarLogic.Month(date), month)
        }
      }
    }
  }

  public func test_compareMonths_shouldWork() {
    for _ in 0..<iterations! {
      /// Setup
      let month1 = RxCalendarLogic.Month(Date.random()!)
      let month2 = RxCalendarLogic.Month(Date.random()!)
      let date1 = month1.date!
      let date2 = month2.date!

      /// When && Then
      XCTAssertEqual(month1 >= month2, date1 >= date2)
    }
  }
}
