//
//  ReduxCalendarTest.swift
//  RxCalendarReduxTests
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import SwiftUtilities
import XCTest
@testable import RxCalendarLogic
@testable import RxCalendarRedux

public final class ReduxCalendarTest: RootTest {}

public extension ReduxCalendarTest {
  public func test_calendarActions_shouldWork() {
    /// Setup
    var state = TreeState<Any>.empty()
    var action: RxCalendarRedux.Calendar.Action!
    var path: String!

    /// When & Then
    let currentMonth = RxCalendarLogic.Month(Date.random()!)
    path = RxCalendarRedux.Calendar.Action.currentMonthPath
    action = RxCalendarRedux.Calendar.Action.updateCurrentMonth(currentMonth)
    state = RxCalendarRedux.Calendar.Reducer.reduce(state, action)
    let storedMonth = state.stateValue(path).value! as! RxCalendarLogic.Month
    XCTAssertEqual(storedMonth, currentMonth)

    path = RxCalendarRedux.Calendar.Action.selectionPath
    let selectionCount = 1000
    let firstWday = Int.random(1, 7)

    let selections = Set((0..<selectionCount)
      .map({(ix: Int) -> RxCalendarLogic.Selection in
        switch ix % 2 {
        case 1:
          return RxCalendarLogic.RepeatWeekdaySelection(Int.random(0, 7), firstWday)

        default:
          return RxCalendarLogic.DateSelection(Date.random()!, firstWday)
        }
      }))

    action = RxCalendarRedux.Calendar.Action.updateSelection(selections)
    state = RxCalendarRedux.Calendar.Reducer.reduce(state, action)
    let storedSl = state.stateValue(path).value! as! Set<RxCalendarLogic.Selection>
    XCTAssertEqual(storedSl, selections)

    action = RxCalendarRedux.Calendar.Action.clearAll
    state = RxCalendarRedux.Calendar.Reducer.reduce(state, action)
    XCTAssertTrue(state.isEmpty)
  }
}
