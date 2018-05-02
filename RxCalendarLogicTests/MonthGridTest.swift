//
//  MonthGridTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 14/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest
import SwiftUtilities
import SwiftUtilitiesTests
import XCTest
@testable import RxCalendarLogic

/// Tests for month grid.
public final class MonthGridTest: RootTest {
  fileprivate var model: RxCalendarLogic.MonthGrid.Model!
  fileprivate var viewModel: RxCalendarLogic.MonthGrid.ViewModel!

  override public func setUp() {
    super.setUp()
    model = RxCalendarLogic.MonthGrid.Model(self)
    viewModel = RxCalendarLogic.MonthGrid.ViewModel(model!)
  }
}

public extension MonthGridTest {
  public func test_injectDependencies_shouldWork() {
    XCTAssertEqual(model!.weekdayStacks, weekdayStacks)
    XCTAssertEqual(viewModel!.weekdayStacks, weekdayStacks)
  }
  
  public func test_gridSelectionReceiverAndStream_shouldWork() {
    /// Setup
    let selectionObs = scheduler!.createObserver(RxCalendarLogic.GridPosition.self)

    viewModel.gridSelectionStream
      .subscribe(selectionObs)
      .disposed(by: disposable!)

    /// When
    for _ in 0..<iterations! {
      let month = Int.random(0, 1000)
      let day = Int.random(0, 1000)
      let selection = RxCalendarLogic.GridPosition(month, day)
      viewModel.gridSelectionReceiver.onNext(selection)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastSelection = selectionObs.nextElements().last!
      XCTAssertEqual(lastSelection, selection)
    }
  }
}

extension MonthGridTest: RxMonthGridModelDependency {
  public var weekdayStacks: Int {
    return RxCalendarLogic.Util.defaultWeekdayStacks
  }
}
