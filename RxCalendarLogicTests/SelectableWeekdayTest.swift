//
//  SelectableWeekdayTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 15/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import SwiftUtilities
import XCTest
@testable import RxCalendarLogic

/// Tests for selectable weekday display.
public final class SelectableWeekdayTest: RootTest {
  fileprivate var model: RxCalendarLogic.SelectWeekday.Model!
  fileprivate var viewModel: RxCalendarLogic.SelectWeekday.ViewModel!
  fileprivate var allSelectionSb: BehaviorSubject<Try<Set<RxCalendarLogic.Selection>>>!
  fileprivate var currentMonth: RxCalendarLogic.Month!
  fileprivate var currentMonthSb: BehaviorSubject<RxCalendarLogic.Month>!

  override public func setUp() {
    super.setUp()
    model = RxCalendarLogic.SelectWeekday.Model(self)
    viewModel = RxCalendarLogic.SelectWeekday.ViewModel(model!)
    allSelectionSb = BehaviorSubject(value: Try.failure(""))
    currentMonth = RxCalendarLogic.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
  }
}

public extension SelectableWeekdayTest {
  public func test_multipleConstructors_shouldWork() {
    let weekdayModel = RxCalendarLogic.WeekdayDisplay.Model(self)
    let model1 = RxCalendarLogic.SelectWeekday.Model(weekdayModel, self)
    
    for weekday in 1...7 {
      XCTAssertEqual(model!.weekdayDescription(weekday),
                     model1.weekdayDescription(weekday))
    }

    
    let weekdays = try! viewModel!.weekdayStream.take(1).toBlocking().first()!
    let weekdayCount = RxCalendarLogic.Util.weekdayCount
    let weekdayRange = RxCalendarLogic.Util.weekdayRange(firstWeekday, weekdayCount)
    XCTAssertEqual(weekdayRange, weekdays.map({$0.weekday}))
    
    let weekdayVM = RxCalendarLogic.WeekdayDisplay.ViewModel(weekdayModel)
    let viewModel1 = RxCalendarLogic.SelectWeekday.ViewModel(weekdayVM, model1)
    let weekdays1 = try! viewModel1.weekdayStream.take(1).toBlocking().first()
    XCTAssertEqual(weekdays1, weekdays)
  }
  
  public func test_selectWeekday_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    viewModel!.setupWeekDisplayBindings()

    /// When && Then
    for i in 0..<iterations! {
      let currentMonth = self.currentMonth!.with(monthOffset: i)
      currentMonthSb.onNext(currentMonth!)
      waitOnMainThread(waitDuration!)

      for weekdayIndex in 0..<6 {
        viewModel!.weekdaySelectionIndexReceiver.onNext(weekdayIndex)
        let weekday = RxCalendarLogic.Util.weekdayWithIndex(weekdayIndex, firstWeekday)
        var selections = try! allSelectionSb.value().getOrElse([])
        XCTAssertGreaterThanOrEqual(selections.count, 4)

        selections
          .flatMap({$0 as? RxCalendarLogic.DateSelection})
          .map({calendar.component(.weekday, from: $0.date)})
          .forEach({XCTAssertEqual($0, weekday)})

        viewModel!.weekdaySelectionIndexReceiver.onNext(weekdayIndex)
        selections = try! allSelectionSb.value().value!
        XCTAssertEqual(selections.count, 0)
      }
    }
  }
}

extension SelectableWeekdayTest: RxSelectWeekdayModelDependency {
  public var firstWeekday: Int {
    return firstWeekdayForTest!
  }
  
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return allSelectionSb.mapObserver(Try.success)
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return allSelectionSb.asObservable()
  }

  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return currentMonthSb.asObservable()
  }
  
  public func weekdayDescription(_ weekday: Int) -> String {
    return RxCalendarLogic.Util.defaultWeekdayDescription(weekday)
  }
}
