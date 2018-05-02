//
//  MonthDisplayViewModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month display view.
public protocol RxMonthDisplayViewModelType:
  RxMonthControlViewModelType,
  RxMonthGridViewModelType,
  RxSelectHighlightFunction,
  RxSingleDaySelectionViewModelType
{
  /// Stream days to display on the month view.
  var dayStream: Observable<[RxCalendarLogic.Day]> { get }

  /// Stream day index selections changed based on the selected dates. These
  /// indexes can be used to reload the cells with said selected dates. Beware
  /// that this stream only emits changes between the previous and current
  /// selections.
  ///
  /// For e.g., the previous selections were [1, 2, 3] and the new selections
  /// are [1, 2, 3, 4], only 4 is emitted.
  ///
  /// We only return the day indexes because for this view since there is only
  /// one month active at any time.
  var gridDayIndexSelectionChangesStream: Observable<Set<Int>> { get }

  /// Set up month display bindings.
  func setupMonthDisplayBindings()
}

// MARK: - All bindings.
public extension RxMonthDisplayViewModelType {
  public func setupAllBindingsAndSubBindings() {
    setupMonthControlBindings()
    setupDaySelectionBindings()
    setupMonthDisplayBindings()
  }
}

public extension RxCalendarLogic.MonthDisplay {

  /// Month display view model implementation.
  public final class ViewModel {
    fileprivate let monthControlVM: RxMonthControlViewModelType
    fileprivate let monthGridVM: RxMonthGridViewModelType
    fileprivate let daySelectionVM: RxSingleDaySelectionViewModelType
    fileprivate let model: RxMonthDisplayModelType
    fileprivate let daySbj: BehaviorSubject<[RxCalendarLogic.Day]?>
    fileprivate let disposable: DisposeBag

    required public init(_ monthControlVM: RxMonthControlViewModelType,
                         _ monthGridVM: RxMonthGridViewModelType,
                         _ daySelectionVM: RxSingleDaySelectionViewModelType,
                         _ model: RxMonthDisplayModelType) {
      self.monthControlVM = monthControlVM
      self.monthGridVM = monthGridVM
      self.daySelectionVM = daySelectionVM
      self.model = model
      disposable = DisposeBag()
      daySbj = BehaviorSubject(value: nil)
    }

    convenience public init(_ model: RxMonthDisplayModelType) {
      let monthControlVM = RxCalendarLogic.MonthControl.ViewModel(model)
      let monthGridVM = RxCalendarLogic.MonthGrid.ViewModel(model)
      let daySelectionVM = RxCalendarLogic.DaySelect.ViewModel(model)
      self.init(monthControlVM, monthGridVM, daySelectionVM, model)
    }
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthDisplay.ViewModel: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return monthControlVM.currentMonthReceiver
  }
}

// MARK: - RxMonthControlViewModelType
extension RxCalendarLogic.MonthDisplay.ViewModel: RxMonthControlViewModelType {
  public var currentMonthForwardReceiver: AnyObserver<Void> {
    return monthControlVM.currentMonthForwardReceiver
  }

  public var currentMonthBackwardReceiver: AnyObserver<Void> {
    return monthControlVM.currentMonthBackwardReceiver
  }

  public func setupMonthControlBindings() {
    monthControlVM.setupMonthControlBindings()
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLogic.MonthDisplay.ViewModel: RxGridDisplayFunction {
  public var weekdayStacks: Int { return monthGridVM.weekdayStacks }
}

// MARK: - RxMonthGridViewModelType
extension RxCalendarLogic.MonthDisplay.ViewModel: RxMonthGridViewModelType {
  public var gridSelectionReceiver: AnyObserver<RxCalendarLogic.GridPosition> {
    return monthGridVM.gridSelectionReceiver
  }

  public var gridSelectionStream: Observable<RxCalendarLogic.GridPosition> {
    return monthGridVM.gridSelectionStream
  }
}

// MARK: - RxSelectHighlightFunction
extension RxCalendarLogic.MonthDisplay.ViewModel: RxSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return model.highlightPart(date)
  }
}

// MARK: - RxMonthDisplayViewModelType
extension RxCalendarLogic.MonthDisplay.ViewModel: RxMonthDisplayViewModelType {
  public var dayStream: Observable<[RxCalendarLogic.Day]> {
    return daySbj.filter({$0.isSome}).map({$0!})
  }

  /// Convenient stream that emits month components.
  private var monthCompStream: Observable<RxCalendarLogic.MonthComp> {
    let dayCount = weekdayStacks * RxCalendarLogic.Util.weekdayCount
    let firstWeekday = model.firstWeekday
    
    return model.currentMonthStream
      .map({RxCalendarLogic.MonthComp($0, dayCount, firstWeekday)})
  }

  public var gridDayIndexSelectionChangesStream: Observable<Set<Int>> {
    return model.allSelectionStream.map({$0.getOrElse([])})
      .scan((p: Set<RxCalendarLogic.Selection>(), c: Set<RxCalendarLogic.Selection>()),
            accumulator: {(p: $0.c, c: $1)})
      .withLatestFrom(monthCompStream) {($1, $0)}
      .map({[weak self] in self?.model
        .gridSelectionChanges($0, $1.p, $1.c)})
      .filter({$0.isSome}).map({$0!})
      .map({Set($0.map({$0.dayIndex}))})
  }

  public func setupMonthDisplayBindings() {
    // Every time the user switches month, we need to update the day stream.
    model.currentMonthStream
      .map({[weak self] month in self?.model.dayRange(month)})
      .filter({$0.isSome}).map({$0!})
      .map(Optional.some)
      .subscribe(daySbj)
      .disposed(by: disposable)

    // We only take the dayIndex because this view has no sections.
    gridSelectionStream
      .withLatestFrom(dayStream) {($1, $0)}
      .filter({$1.dayIndex >= 0 && $1.dayIndex < $0.count})
      .map({(days, index) in days[index.dayIndex].date})
      .subscribe(dateSelectionReceiver)
      .disposed(by: disposable)
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarLogic.MonthDisplay.ViewModel: RxSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionVM.isDateSelected(date)
  }
}

// MARK: - RxDaySelectionViewModelType
extension RxCalendarLogic.MonthDisplay.ViewModel: RxSingleDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return daySelectionVM.dateSelectionReceiver
  }

  public func setupDaySelectionBindings() {
    daySelectionVM.setupDaySelectionBindings()
  }
}
