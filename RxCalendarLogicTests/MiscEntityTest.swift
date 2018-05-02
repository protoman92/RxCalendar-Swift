//
//  MiscEntityTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import RxCalendarLogic

public final class MiscEntityTest: RootTest {
  override public func setUp() {
    super.setUp()
    iterations = 10000
  }

  public func test_dayImplementation_shouldWorkCorrectly() {
    /// Setup
    let calendar = Calendar.current

    let highlightParts = [RxCalendarLogic.HighlightPart.startAndEnd,
                          .start, .end, .mid, .none]

    /// When
    for _ in 0..<iterations {
      let isToday = Bool.random()
      let date = isToday ? Date() : Date.random()!
      let dateComponent = calendar.component(.day, from: date)
      let description = String(dateComponent)
      let isCurrentMonth = Bool.random()
      let isSelected = Bool.random()
      let highlightPart = highlightParts.randomElement()!

      let day1 = RxCalendarLogic.Day(date)
        .with(dateDescription: description)
        .with(currentMonth: isCurrentMonth)
        .with(selected: isSelected)
        .with(highlightPart: highlightPart)

      let day2 = RxCalendarLogic.Day(date)
        .with(dateDescription: description)
        .with(currentMonth: isCurrentMonth)
        .with(selected: isSelected)
        .with(highlightPart: highlightPart)

      XCTAssertEqual(day1.isToday, isToday)
      XCTAssertNotEqual(day1.isSelected, day1.toggleSelection().isSelected)
      XCTAssertEqual(day1, day2)
    }
  }

  public func test_weekdayImplementation_shouldWorkCorrectly() {
    /// Setup & When
    for _ in 0..<iterations! {
      for weekday in 1...7 {
        let wd1 = RxCalendarLogic.Weekday(weekday, String(describing: weekday))
        let wd2 = RxCalendarLogic.Weekday(weekday, String(describing: weekday))

        /// Then
        XCTAssertEqual(wd1, wd2)
      }
    }
  }

  public func test_monthImplementation_shouldWorkCorrectly() {
    /// Setup && When && Then
    for _ in 0..<iterations! {
      let month1 = RxCalendarLogic.Month(Date())
      let month2 = RxCalendarLogic.Month(Date())

      /// Then
      XCTAssertEqual(month1.hashValue, month2.hashValue)
    }
  }
  
  public func test_monthCompEquality_shouldWork() {
    /// Setup && When && Then
    for _ in 0..<iterations! {
      let shouldEqual = Bool.random()
      let month1: RxCalendarLogic.Month
      let month2: RxCalendarLogic.Month
      let dayCount1: Int
      let dayCount2: Int
      let firstWeekday1: Int
      let firstWeekday2: Int
      
      if shouldEqual {
        month1 = RxCalendarLogic.Month(Date.random()!)
        month2 = month1
        dayCount1 = Int.random(1, 1000)
        dayCount2 = dayCount1
        firstWeekday1 = Int.random(1, 1000)
        firstWeekday2 = firstWeekday1
      } else {
        month1 = RxCalendarLogic.Month(Date.random()!)
        month2 = month1.with(monthOffset: Int.random(1, 1000))!
        dayCount1 = Int.random(1, 1000)
        dayCount2 = dayCount1 + Int.random(1, 1000)
        firstWeekday1 = Int.random(1, 1000)
        firstWeekday2 = firstWeekday1 + Int.random(1, 1000)
      }
      
      let monthComp1 = RxCalendarLogic.MonthComp(month1, dayCount1, firstWeekday1)
      let monthComp2 = RxCalendarLogic.MonthComp(month2, dayCount2, firstWeekday2)
      XCTAssertEqual(monthComp1 == monthComp2, shouldEqual)
    }
  }

  public func test_hightlightPosition_shouldWorkCorrectly() {
    XCTAssertTrue(RxCalendarLogic.HighlightPart.startAndEnd.contains(.start))
    XCTAssertTrue(RxCalendarLogic.HighlightPart.startAndEnd.contains(.end))
    XCTAssertFalse(RxCalendarLogic.HighlightPart.startAndEnd.contains(.mid))
  }
}
