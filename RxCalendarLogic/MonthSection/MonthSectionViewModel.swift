//
//  MonthSectionViewModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month section view.
public protocol RxMonthSectionViewModelType:
  RxMonthControlViewModelType,
  RxMonthGridViewModelType,
  RxSelectHighlightFunction,
  RxSingleDaySelectionViewModelType
{
  /// Get the total month count.
  var totalMonthCount: Int { get }
  
  /// Stream month components to display on the month section view.
  var monthCompStream: Observable<[RxCalendarLogic.MonthComp]> { get }

  /// Stream the current month selection index. This will change, for e.g. when
  /// the user swipes the calendar view to reveal a new month.
  var currentMonthSelectionIndexStream: Observable<Int> { get }

  /// Stream grid selections changes based on selected dates. We need to
  /// calculate the grid selections in a way that memory usage is minimized.
  ///
  /// Beware that this stream only emits changes in grid selections by comparing
  /// the previous and current selections.
  var gridSelectionChangesStream: Observable<Set<RxCalendarLogic.GridPosition>> { get }

  /// Calculate the day for a month and a first date offset.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func dayFromFirstDate(_ month: RxCalendarLogic.Month,
                        _ firstDateOffset: Int) -> RxCalendarLogic.Day?

  /// Set up month section bindings.
  func setupMonthSectionBindings()
}

// MARK: - All bindings.
public extension RxMonthSectionViewModelType {

  /// Set up all bindings and sub-bindings.
  public func setupAllBindingsAndSubBindings() {
    setupDaySelectionBindings()
    setupMonthControlBindings()
    setupMonthSectionBindings()
  }
}

/// Factory for month section view model.
public protocol RxMonthSectionViewModelFactory {

  /// Get a month section view model.
  ///
  /// - Returns: A RxMonthSectionViewModelType instance.
  func monthSectionViewModel() -> RxMonthSectionViewModelType
}

public extension RxCalendarLogic.MonthSection {

  /// View model implementation for the month section view.
  public final class ViewModel {
    fileprivate let monthControlVM: RxMonthControlViewModelType
    fileprivate let monthGridVM: RxMonthGridViewModelType
    fileprivate let daySelectionVM: RxSingleDaySelectionViewModelType
    fileprivate let model: RxMonthSectionModelType
    fileprivate let disposable: DisposeBag

    /// Cache here to improve performance.
    fileprivate let monthCompSbj: BehaviorSubject<[RxCalendarLogic.MonthComp]?>

    required public init(_ monthControlVM: RxMonthControlViewModelType,
                         _ monthGridVM: RxMonthGridViewModelType,
                         _ daySelectionVM: RxSingleDaySelectionViewModelType,
                         _ model: RxMonthSectionModelType) {
      self.monthControlVM = monthControlVM
      self.monthGridVM = monthGridVM
      self.daySelectionVM = daySelectionVM
      self.model = model
      monthCompSbj = BehaviorSubject(value: nil)
      disposable = DisposeBag()
    }

    convenience public init(_ model: RxMonthSectionModelType) {
      let monthControlVM = RxCalendarLogic.MonthControl.ViewModel(model)
      let monthGridVM = RxCalendarLogic.MonthGrid.ViewModel(model)
      let daySelectionVM = RxCalendarLogic.DaySelect.ViewModel(model)
      self.init(monthControlVM, monthGridVM, daySelectionVM, model)
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLogic.MonthSection.ViewModel: RxGridDisplayFunction {
  public var weekdayStacks: Int { return monthGridVM.weekdayStacks }
}

// MARK: - RxMonthGridViewModelType
extension RxCalendarLogic.MonthSection.ViewModel: RxMonthGridViewModelType {
  public var gridSelectionReceiver: AnyObserver<RxCalendarLogic.GridPosition> {
    return monthGridVM.gridSelectionReceiver
  }

  public var gridSelectionStream: Observable<RxCalendarLogic.GridPosition> {
    return monthGridVM.gridSelectionStream
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthSection.ViewModel: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return monthControlVM.currentMonthReceiver
  }
}

// MARK: - RxMonthControlViewModelType
extension RxCalendarLogic.MonthSection.ViewModel: RxMonthControlViewModelType {
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

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarLogic.MonthSection.ViewModel: RxSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionVM.isDateSelected(date)
  }
}

// MARK: - RxDaySelectionViewModelType
extension RxCalendarLogic.MonthSection.ViewModel: RxSingleDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return daySelectionVM.dateSelectionReceiver
  }

  public func setupDaySelectionBindings() {
    daySelectionVM.setupDaySelectionBindings()
  }
}

// MARK: - RxSelectHighlightFunction
extension RxCalendarLogic.MonthSection.ViewModel: RxSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return model.highlightPart(date)
  }
}

// MARK: - RxMonthSectionViewModelType
extension RxCalendarLogic.MonthSection.ViewModel: RxMonthSectionViewModelType {
  public var totalMonthCount: Int {
    return RxCalendarLogic.Util.monthCount(model.minimumMonth, model.maximumMonth)
  }

  public var monthCompStream: Observable<[RxCalendarLogic.MonthComp]> {
    return monthCompSbj.filter({$0.isSome}).map({$0!})
  }

  public var currentMonthSelectionIndexStream: Observable<Int> {
    return model.currentMonthStream
      .withLatestFrom(monthCompStream) {($0, $1)}
      .map({$1.map({$0.month}).index(of: $0)})
      .filter({$0.isSome}).map({$0!})
  }

  /// Keep track of the previous selections to know what have been deselected.
  public var gridSelectionChangesStream: Observable<Set<RxCalendarLogic.GridPosition>> {
    return model.allSelectionStream.map({$0.getOrElse([])})
      .scan((p: Set<RxCalendarLogic.Selection>(), c: Set<RxCalendarLogic.Selection>()),
            accumulator: {(p: $0.c, c: $1)})
      .withLatestFrom(model.currentMonthStream) {($1, p: $0.p, c: $0.c)}
      .withLatestFrom(monthCompStream) {($1, $0.0, p: $0.p, c: $0.c)}
      .map({[weak self] in self?.model.gridSelectionChanges($0.0, $0.1, $0.p, $0.c)})
      .filter({$0.isSome}).map({$0!})
  }

  public func dayFromFirstDate(_ month: RxCalendarLogic.Month,
                               _ firstDateOffset: Int) -> RxCalendarLogic.Day? {
    return model.dayFromFirstDate(month, firstDateOffset)
  }

  public func setupMonthSectionBindings() {
    let disposable = self.disposable
    let minMonth = model.minimumMonth
    let maxMonth = model.maximumMonth
    let dayCount = monthGridVM.weekdayStacks * RxCalendarLogic.Util.weekdayCount
    let firstWeekday = model.firstWeekday

    /// Must call onNext manually to avoid completed event, since this is a
    /// cold stream.
    Observable.just(RxCalendarLogic.Util.monthRange(minMonth, maxMonth))
      .map({$0.map({RxCalendarLogic.MonthComp($0, dayCount, firstWeekday)})})
      .subscribe(onNext: {[weak self] in self?.monthCompSbj.onNext($0)})
      .disposed(by: disposable)

    gridSelectionStream
      .withLatestFrom(monthCompStream) {($1, $0)}
      .filter({$1.monthIndex >= 0 && $1.monthIndex < $0.count})
      .map({[weak self] (months, index) -> Date? in
        let month = months[index.monthIndex].month
        return self?.dayFromFirstDate(month, index.dayIndex)?.date
      })
      .filter({$0.isSome}).map({$0!})
      .subscribe(dateSelectionReceiver)
      .disposed(by: disposable)
  }
}
