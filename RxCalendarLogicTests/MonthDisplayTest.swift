//
//  MonthDisplayTest.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import SwiftUtilities
import XCTest
@testable import RxCalendarLogic

public final class MonthDisplayTest: RootTest {
  fileprivate var model: RxCalendarLogic.MonthDisplay.Model!
  fileprivate var viewModel: RxCalendarLogic.MonthDisplay.ViewModel!
  fileprivate var currentMonth: RxCalendarLogic.Month!
  fileprivate var currentMonthSb: BehaviorSubject<RxCalendarLogic.Month>!
  fileprivate var allSelectionSb: BehaviorSubject<Try<Set<RxCalendarLogic.Selection>>>!

  override public func setUp() {
    super.setUp()
    model = RxCalendarLogic.MonthDisplay.Model(self)
    viewModel = RxCalendarLogic.MonthDisplay.ViewModel(model)
    currentMonth = RxCalendarLogic.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
    allSelectionSb = BehaviorSubject(value: Try.failure(""))
  }
}

extension MonthDisplayTest: MonthControlCommonTestProtocol {
  public func test_backwardAndForwardReceiver_shouldWork() {
    test_backwardAndForwardReceiver_shouldWork(viewModel!, model!)
  }

  public func test_minAndMaxMonths_shouldLimitMonthSelection() {
    test_minAndMaxMonths_shouldLimitMonthSelection(viewModel!, model!)
  }
}

extension MonthDisplayTest: SelectHighlightCommonTestProtocol {
  public func test_calculateHighlightParts_shouldWorkCorrectly() {
    test_calculateHighlightParts_shouldWorkCorrectly(viewModel!, model!)
  }
}

public extension MonthDisplayTest {
  public func test_multipleConstructors_shouldWork() {
    let monthControlModel = RxCalendarLogic.MonthControl.Model(self)
    let monthGridModel = RxCalendarLogic.MonthGrid.Model(self)
    let daySelectionModel = RxCalendarLogic.DaySelect.Model(self)
    
    let model1 = RxCalendarLogic.MonthDisplay
      .Model(monthControlModel, monthGridModel, daySelectionModel, self)
    
    let initialMonth = try! model!.initialMonthStream.toBlocking().first()!
    let initialMonth1 = try! model1.initialMonthStream.toBlocking().first()!
    XCTAssertEqual(initialMonth, initialMonth1)
    
    let monthControlVM = RxCalendarLogic.MonthControl.ViewModel(monthControlModel)
    let monthGridVM = RxCalendarLogic.MonthGrid.ViewModel(monthGridModel)
    let daySelectionVM = RxCalendarLogic.DaySelect.ViewModel(daySelectionModel)
    
    let viewModel1 = RxCalendarLogic.MonthDisplay.ViewModel(monthControlVM,
                                                            monthGridVM,
                                                            daySelectionVM,
                                                            model1)
    
    viewModel!.setupAllBindingsAndSubBindings()
    viewModel1.setupAllBindingsAndSubBindings()
    XCTAssertEqual(viewModel!.weekdayStacks, viewModel1.weekdayStacks)
    
    XCTAssertEqual(
      try! viewModel!.dayStream.take(1).toBlocking().first(),
      try! viewModel1.dayStream.take(1).toBlocking().first()
    )
  }
  
  public func test_dayStreamForCurrentMonth_shouldWorkCorrectly() {
    /// Setup
    let dayObs = scheduler!.createObserver([RxCalendarLogic.Day].self)
    var currentMonth = self.currentMonth!
    viewModel!.dayStream.subscribe(dayObs).disposed(by: disposable!)
    viewModel!.setupMonthDisplayBindings()
    viewModel!.setupMonthControlBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = Int.random(1, 20)
      currentMonth = currentMonth.with(monthOffset: forward ? jump : -jump)!
      let currentDays = model!.dayRange(currentMonth)
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastDays = dayObs.nextElements().last!
      XCTAssertEqual(lastDays, currentDays)
    }
  }

  public func test_gridSelectionStream_shouldWorkCorrectly() {
    /// Setup
    var currentMonth = self.currentMonth!
    viewModel!.setupMonthDisplayBindings()
    viewModel!.setupMonthControlBindings()
    viewModel!.setupDaySelectionBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!
      let currentDays = model!.dayRange(currentMonth)
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      // This will be ignored anyway, but we add in just to check.
      let monthIndex = Int.random(0, 1000)
      let dayIndex = Int.random(0, 1000)
      let gridPosition = RxCalendarLogic.GridPosition(monthIndex, dayIndex)
      let validSelection = dayIndex < currentDays.count
      let selectedDay = validSelection ? currentDays[dayIndex] : nil
      let wasSelected = selectedDay.map({viewModel!.isDateSelected($0.date)}) ?? false
      viewModel!.gridSelectionReceiver.onNext(gridPosition)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastSelections = try! allSelectionSb.value().getOrElse([])

      // If the date was selected previously, it should be removed from all date
      // selections (thanks to single day selection logic).
      if let selectedDay = selectedDay {
        XCTAssertNotEqual(
          lastSelections.contains(where: {$0.contains(selectedDay.date)}),
          wasSelected)
      }
    }
  }

  public func test_gridSelectionIndexChanges_shouldWorkCorrectly() {
    /// Setup
    let indexChangesObs = scheduler!.createObserver(Set<Int>.self)
    let weekdayStacks = viewModel!.weekdayStacks
    let firstWeekday = model!.firstWeekday
    var currentMonth = self.currentMonth!

    viewModel!.gridDayIndexSelectionChangesStream
      .subscribe(indexChangesObs)
      .disposed(by: disposable!)

    viewModel!.setupMonthControlBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      let dayRange = model!.dayRange(currentMonth)
      let selectedIndex = Int.random(0, weekdayStacks * RxCalendarLogic.Util.weekdayCount)
      let selectedDay = dayRange[selectedIndex]
      let wasSelected = viewModel!.isDateSelected(selectedDay.date)

      allSelectionReceiver.onNext(Set(arrayLiteral:
        RxCalendarLogic.DateSelection(selectedDay.date, firstWeekday)))

      waitOnMainThread(waitDuration!)

      /// Then
      let lastChanges = indexChangesObs.nextElements().last!

      // If this index is already selected previously, it should not appear in
      // in the set of index changes.
      //
      // If we look at a similar test for MonthSectionView (for grid selection
      // changes), we will see that an extra step (navigating to the current
      // month) is added. Said step is not needed here because for this view,
      // there will always be only 1 month active at a time, so the month index
      // (which is used for calculation by the DateSelection object) is fixed.
      XCTAssertEqual(lastChanges.contains(selectedIndex), !wasSelected)
    }
  }
}

extension MonthDisplayTest: RxMonthDisplayModelDependency {
  public var firstWeekday: Int {
    return firstWeekdayForTest!
  }
  
  public var weekdayStacks: Int {
    return RxCalendarLogic.Util.defaultWeekdayStacks
  }
  
  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return allSelectionSb.mapObserver(Try.success)
  }

  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return allSelectionSb.asObservable()
  }

  public var initialMonthStream: Single<RxCalendarLogic.Month> {
    return Single.just(currentMonth!)
  }

  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return currentMonthSb.asObservable()
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return try! allSelectionSb.value()
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }

  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return try! allSelectionSb.value()
      .map({RxCalendarLogic.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
  
  public func gridSelectionChanges(_ monthComp: RxCalendarLogic.MonthComp,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return RxCalendarLogic.Util.defaultGridSelectionChanges(monthComp, prev, current)
  }
}
