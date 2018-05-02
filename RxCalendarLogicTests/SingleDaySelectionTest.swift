//
//  SingleDaySelectionTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import SwiftUtilities
import XCTest
@testable import RxCalendarLogic

/// Tests for single day selection view model.
public final class SingleDaySelectionTest: RootTest {
  fileprivate var model: RxCalendarLogic.DaySelect.Model!
  fileprivate var viewModel: RxCalendarLogic.DaySelect.ViewModel!
  fileprivate var allSelectionSb: BehaviorSubject<Try<Set<RxCalendarLogic.Selection>>>!

  override public func setUp() {
    super.setUp()
    model = RxCalendarLogic.DaySelect.Model(self)
    viewModel = RxCalendarLogic.DaySelect.ViewModel(model!)
    allSelectionSb = BehaviorSubject(value: Try.failure(""))
  }
}

public extension SingleDaySelectionTest {
  public func test_selectSingleDates_shouldUpdateAllSelectionsCorrectly() {
    /// Setup
    viewModel!.setupDaySelectionBindings()
    var previousSelected: Date?

    for _ in 0..<iterations! {
      /// When
      let duplicate = Bool.random() && previousSelected != nil
      var newSelected: Date?

      if duplicate, let prevSelected = previousSelected {
        newSelected = prevSelected
        previousSelected = nil
      } else {
        while newSelected == nil || newSelected == previousSelected {
          newSelected = Date.random()!
        }

        previousSelected = newSelected
      }

      viewModel!.dateSelectionReceiver.onNext(newSelected!)
      waitOnMainThread(waitDuration!)

      /// Then
      XCTAssertNotEqual(viewModel.isDateSelected(newSelected!), duplicate)
    }
  }
}

extension SingleDaySelectionTest: RxSingleDaySelectionModelDependency {
  public var firstWeekday: Int {
    return firstWeekdayForTest!
  }

  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return allSelectionSb.mapObserver(Try.success)
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return allSelectionSb.asObservable()
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return try! allSelectionSb!.value()
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }
}
