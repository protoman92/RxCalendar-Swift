//
//  MonthControlTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftUtilities
import XCTest
@testable import RxCalendarLogic

public final class MonthControlTest: RootTest {
  fileprivate var model: RxCalendarLogic.MonthControl.Model!
  fileprivate var viewModel: RxMonthControlViewModelType!
  fileprivate var currentMonth: RxCalendarLogic.Month!
  fileprivate var currentMonthSb: BehaviorSubject<RxCalendarLogic.Month>!

  override public func setUp() {
    super.setUp()
    model = RxCalendarLogic.MonthControl.Model(self)
    viewModel = RxCalendarLogic.MonthControl.ViewModel(model!)
    currentMonth = RxCalendarLogic.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
  }
}

public extension MonthControlTest {
  public func test_navigateToPreviousOrNextMonth_shouldWork() {
    /// Setup
    viewModel!.setupMonthControlBindings()
    var prevMonth = currentMonth!

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let currentMonth = prevMonth.with(monthOffset: forward ? 1 : -1)!
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      /// Then
      let monthOffset = prevMonth.monthOffset(from: currentMonth)
      prevMonth = currentMonth
      XCTAssertEqual(monthOffset, forward ? -1 : 1)
    }
  }
}

extension MonthControlTest: RxMonthControlModelDependency {
  public var initialMonthStream: Single<RxCalendarLogic.Month> {
    return currentMonthSb.take(1).asSingle()
  }

  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return currentMonthSb.asObservable()
  }
}
