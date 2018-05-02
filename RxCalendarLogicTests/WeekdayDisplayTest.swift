//
//  WeekdayDisplayTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 14/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest
import XCTest
@testable import RxCalendarLogic

/// Tests for weekday display.
public final class WeekdayDisplayTest: RootTest {
  fileprivate var model: RxCalendarLogic.WeekdayDisplay.Model!
  fileprivate var viewModel: RxCalendarLogic.WeekdayDisplay.ViewModel!

  override public func setUp() {
    super.setUp()
    model = RxCalendarLogic.WeekdayDisplay.Model(self)
    viewModel = RxCalendarLogic.WeekdayDisplay.ViewModel(model)
  }
}

public extension WeekdayDisplayTest {
  public func test_weekdayStream_shouldEmitCorrectWeekdays() {
    /// Setup
    let weekdayObserver = scheduler!.createObserver([RxCalendarLogic.Weekday].self)
    viewModel!.weekdayStream.subscribe(weekdayObserver).disposed(by: disposable)
    viewModel!.setupWeekDisplayBindings()

    /// When & Then
    let weekdayCount = RxCalendarLogic.Util.weekdayCount
    let firstWeekday = model!.firstWeekday
    let actualRange = RxCalendarLogic.Util.weekdayRange(firstWeekday, weekdayCount)

    let emittedWeekdays = weekdayObserver.nextElements()
      .flatMap({$0.map({$0.weekday})})

    XCTAssertEqual(emittedWeekdays, actualRange)
  }

  public func test_weekdaySelection_shouldWork() {
    /// Setup
    let selectionObs = scheduler!.createObserver(Int.self)
    let indexRange = (0..<RxCalendarLogic.Util.weekdayCount).map({$0})
    let firstWeekday = model!.firstWeekday
    let weekdayRange = indexRange.map({RxCalendarLogic.Util.weekdayWithIndex($0, firstWeekday)})
    viewModel!.weekdaySelectionStream.subscribe(selectionObs).disposed(by: disposable)
    viewModel!.setupWeekDisplayBindings()

    /// When
    indexRange.forEach(viewModel!.weekdaySelectionIndexReceiver.onNext)

    /// Then
    XCTAssertEqual(weekdayRange, selectionObs.nextElements())
  }
}

extension WeekdayDisplayTest: RxWeekdayDisplayModelDependency {
  public var firstWeekday: Int { return firstWeekdayForTest! }

  public func weekdayDescription(_ weekday: Int) -> String {
    return RxCalendarLogic.Util.defaultWeekdayDescription(weekday)
  }
}

