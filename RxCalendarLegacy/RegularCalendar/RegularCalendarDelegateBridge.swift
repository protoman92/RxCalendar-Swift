//
//  RegularCalendarDelegateBridge.swift
//  RxCalendarLegacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

// MARK: - Delegate bridge.
extension RxCalendarLegacy.RegularCalendar {

  /// Delegate bridge for RegularCalendar preset.
  final class Bridge {
    fileprivate weak var calendar: RxRegularCalendar?
    fileprivate let delegate: RxRegularCalendarDelegate?
    fileprivate let currentMonthSb: BehaviorSubject<Void>
    fileprivate let selectionSb: BehaviorSubject<Void>

    private init(_ delegate: RxRegularCalendarDelegate) {
      self.delegate = delegate
      currentMonthSb = BehaviorSubject(value: ())
      selectionSb = BehaviorSubject(value: ())
    }

    convenience init(_ calendar: RxRegularCalendar,
                     _ delegate: RxRegularCalendarDelegate) {
      self.init(Wrapper(delegate))
      self.calendar = calendar
    }

    convenience init(_ calendar: RxRegularCalendar,
                     _ delegate: RxRegularCalendarNoDefaultDelegate) {
      self.init(DefaultDelegate(delegate))
      self.calendar = calendar
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxGridDisplayFunction {
  var weekdayStacks: Int {
    return calendar.zipWith(delegate, {$1.weekdayStacks(for: $0)}).getOrElse(0)
  }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxMonthAwareModelFunction {
  var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return currentMonthSb
      .map({[weak self] in (self?.calendar)
        .zipWith(self?.delegate, {$1.currentMonth(for: $0)})
        .flatMap({$0})})
      .filter({$0.isSome}).map({$0!})
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxMonthControlFunction {
  var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return currentMonthSb.mapObserver({[weak self] month -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regularCalendar($0, currentMonthChanged: month)
      })
    })
  }
}

// MARK: - RxMonthControlModelFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxMonthControlModelFunction {
  var minimumMonth: RxCalendarLogic.Month {
    return calendar
      .zipWith(delegate, {$1.minimumMonth(for: $0)})
      .getOrElse(RxCalendarLogic.Month(Date()))
  }

  var maximumMonth: RxCalendarLogic.Month {
    return calendar
      .zipWith(delegate, {$1.maximumMonth(for: $0)})
      .getOrElse(RxCalendarLogic.Month(Date()))
  }

  var initialMonthStream: Single<RxCalendarLogic.Month> {
    return Single.just(calendar.zipWith(delegate, {$1.initialMonth(for: $0)})
      .getOrElse(RxCalendarLogic.Month(Date())))
  }
}

// MARK: - RxMonthHeaderModelFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxMonthHeaderModelFunction {
  func formatMonthDescription(_ month: RxCalendarLogic.Month) -> String {
    return calendar
      .zipWith(delegate, {$1.regularCalendar($0, monthDescriptionFor: month)})
      .getOrElse("")
  }
}

// MARK: - RxMultiDaySelectionFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxMultiDaySelectionFunction {
  var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return selectionSb.mapObserver({[weak self] selection -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regularCalendar($0, selectionChanged: selection)
      })})
  }

  var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    return selectionSb
      .map({[weak self] in (self?.calendar)
        .zipWith(self?.delegate, {$1.currentSelections(for: $0)})
      })
      .filter({$0.isSome}).map({$0!.asTry()})
  }
}

// MARK: - RxMultiMonthGridSelectionCalculator
extension RxCalendarLegacy.RegularCalendar.Bridge: RxMultiMonthGridSelectionCalculator {
  func gridSelectionChanges(_ monthComps: [RxCalendarLogic.MonthComp],
                            _ currentMonth: RxCalendarLogic.Month,
                            _ prev: Set<RxCalendarLogic.Selection>,
                            _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return calendar
      .zipWith(delegate, {
        $1.regularCalendar($0, gridSelectionChangesFor: monthComps,
                           whileCurrentMonthIs: currentMonth,
                           withPreviousSelection: prev,
                           andCurrentSelection: current)})
      .getOrElse([])
  }
}

// MARK: - RxSelectHighlightFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxSelectHighlightFunction {
  func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return calendar
      .zipWith(delegate, {$1.regularCalendar($0, highlightPartFor: date)})
      .getOrElse(.none)
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxSingleDaySelectionFunction {
  func isDateSelected(_ date: Date) -> Bool {
    return calendar
      .zipWith(delegate, {$1.regularCalendar($0, isDateSelected: date)})
      .getOrElse(false)
  }
}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxWeekdayAwareModelFunction {
  var firstWeekday: Int {
    return calendar.zipWith(delegate, {$1.firstWeekday(for: $0)}).getOrElse(1)
  }
}

// MARK: - RxWeekdayDisplayModelFunction
extension RxCalendarLegacy.RegularCalendar.Bridge: RxWeekdayDisplayModelFunction {
  func weekdayDescription(_ weekday: Int) -> String {
    return calendar
      .zipWith(delegate, {$1.regularCalendar($0, weekdayDescriptionFor: weekday)})
      .getOrElse("")
  }
}

// MARK: - RxRegularCalendarModelDependency
extension RxCalendarLegacy.RegularCalendar.Bridge: RxRegularCalendarModelDependency {}

// MARK: - Delegate wrapper.
extension RxCalendarLegacy.RegularCalendar.Bridge {

  /// Wrapper for delegate to store reference weakly. This is because we need
  /// to store a strong reference to the delegate in the bridge class to cater
  /// to default dependencies.
  final class Wrapper: RxRegularCalendarDelegate {
    private weak var delegate: RxRegularCalendarDelegate?

    init(_ delegate: RxRegularCalendarDelegate) {
      self.delegate = delegate
    }

    /// Defaultable.
    func firstWeekday(for calendar: RxRegularCalendar) -> Int {
      return delegate?.firstWeekday(for: calendar) ?? 1
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         weekdayDescriptionFor weekday: Int) -> String {
      return delegate?.regularCalendar(calendar, weekdayDescriptionFor: weekday) ?? ""
    }

    func weekdayStacks(for calendar: RxRegularCalendar) -> Int {
      return delegate?.weekdayStacks(for: calendar) ?? 0
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         monthDescriptionFor month: RxCalendarLogic.Month) -> String {
      return RxCalendarLogic.Util.defaultMonthDescription(month)
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         gridSelectionChangesFor months: [RxCalendarLogic.MonthComp],
                         whileCurrentMonthIs month: RxCalendarLogic.Month,
                         withPreviousSelection prev: Set<RxCalendarLogic.Selection>,
                         andCurrentSelection current: Set<RxCalendarLogic.Selection>)
      -> Set<RxCalendarLogic.GridPosition>
    {
      return delegate?.regularCalendar(calendar,
                                       gridSelectionChangesFor: months,
                                       whileCurrentMonthIs: month,
                                       withPreviousSelection: prev,
                                       andCurrentSelection: current) ?? []
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
      return delegate
        .map({$0.minimumMonth(for: calendar)})
        .getOrElse(RxCalendarLogic.Month(Date()))
    }

    func maximumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
      return delegate
        .map({$0.maximumMonth(for: calendar)})
        .getOrElse(RxCalendarLogic.Month(Date()))
    }

    func initialMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
      return delegate
        .map({$0.initialMonth(for: calendar)})
        .getOrElse(RxCalendarLogic.Month(Date()))
    }

    func currentMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month? {
      return delegate?.currentMonth(for: calendar)
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         currentMonthChanged month: RxCalendarLogic.Month) {
      delegate?.regularCalendar(calendar, currentMonthChanged: month)
    }

    func currentSelections(for calendar: RxRegularCalendar) -> Set<RxCalendarLogic.Selection>? {
      return delegate?.currentSelections(for: calendar) ?? []
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         selectionChanged selections: Set<RxCalendarLogic.Selection>) {
      delegate?.regularCalendar(calendar, selectionChanged: selections)
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         isDateSelected date: Date) -> Bool {
      return delegate?.regularCalendar(calendar, isDateSelected: date) ?? false
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         highlightPartFor date: Date) -> RxCalendarLogic.HighlightPart {
      return delegate?.regularCalendar(calendar, highlightPartFor: date) ?? .none
    }
  }
}

// MARK: - Default delegate
extension RxCalendarLegacy.RegularCalendar.Bridge {

  /// This default delegate also includes embedded storage for current month
  /// and selections, all of which are guarded by a lock for concurrent access.
  /// As a result, using these defaults will dramatically reduce the number of
  /// methods to be implemented by a delegate.
  final class DefaultDelegate: RxRegularCalendarDelegate {
    private weak var delegate: RxRegularCalendarNoDefaultDelegate?
    private let highlightCalc: RxCalendarLogic.DateCalc.HighlightPart
    private let lock: NSLock
    private var _currentMonth: RxCalendarLogic.Month?
    private var _currentSelections: Set<RxCalendarLogic.Selection>?

    private var currentMonth: RxCalendarLogic.Month? {
      get { lock.lock(); defer { lock.unlock() }; return _currentMonth }
      set { lock.lock(); defer { lock.unlock() }; _currentMonth = newValue }
    }

    private var currentSelections: Set<RxCalendarLogic.Selection>? {
      get { lock.lock(); defer { lock.unlock() }; return _currentSelections }
      set { lock.lock(); defer { lock.unlock() }; _currentSelections = newValue }
    }

    init(_ delegate: RxRegularCalendarNoDefaultDelegate) {
      self.delegate = delegate
      let weekdayStacks = 6
      let sequentialCalc = RxCalendarLogic.DateCalc.Default(weekdayStacks, 1)
      highlightCalc = RxCalendarLogic.DateCalc.HighlightPart(sequentialCalc, weekdayStacks)
      lock = NSLock()
    }

    /// Defaultable.
    func firstWeekday(for calendar: RxRegularCalendar) -> Int {
      return 1
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         weekdayDescriptionFor weekday: Int) -> String {
      return RxCalendarLogic.Util.defaultWeekdayDescription(weekday)
    }

    func weekdayStacks(for calendar: RxRegularCalendar) -> Int {
      return highlightCalc.weekdayStacks
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         monthDescriptionFor month: RxCalendarLogic.Month) -> String {
      return RxCalendarLogic.Util.defaultMonthDescription(month)
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         gridSelectionChangesFor months: [RxCalendarLogic.MonthComp],
                         whileCurrentMonthIs month: RxCalendarLogic.Month,
                         withPreviousSelection prev: Set<RxCalendarLogic.Selection>,
                         andCurrentSelection current: Set<RxCalendarLogic.Selection>)
      -> Set<RxCalendarLogic.GridPosition>
    {
      return highlightCalc.gridSelectionChanges(months, month, prev, current)
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
      return delegate?.minimumMonth(for: calendar) ?? RxCalendarLogic.Month(Date())
    }

    func maximumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
      return delegate?.maximumMonth(for: calendar) ?? RxCalendarLogic.Month(Date())
    }

    func initialMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month {
      return delegate?.initialMonth(for: calendar) ?? RxCalendarLogic.Month(Date())
    }

    func currentMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month? {
      return currentMonth
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         currentMonthChanged month: RxCalendarLogic.Month) {
      currentMonth = month
      delegate?.regularCalendar(calendar, currentMonthChanged: month)
    }

    func currentSelections(for calendar: RxRegularCalendar) -> Set<RxCalendarLogic.Selection>? {
      return currentSelections
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         selectionChanged selections: Set<RxCalendarLogic.Selection>) {
      currentSelections = selections
      delegate?.regularCalendar(calendar, selectionChanged: selections)
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         isDateSelected date: Date) -> Bool {
      return currentSelections
        .map({$0.contains(where: {$0.contains(date)})})
        .getOrElse(false)
    }

    func regularCalendar(_ calendar: RxRegularCalendar,
                         highlightPartFor date: Date) -> RxCalendarLogic.HighlightPart {
      return currentSelections
        .map({RxCalendarLogic.Util.highlightPart($0, date)})
        .getOrElse(.none)
    }
  }
}

// MARK: - Delegate bridge
public extension RxRegularCalendar {
  public typealias NoDefaultDelegate = RxRegularCalendarNoDefaultDelegate
  public typealias Delegate = RxRegularCalendarDelegate
  public typealias NoDefaultLegacyDependency = (NoDefaultDelegate, Decorator)
  public typealias LegacyDependency = (Delegate, Decorator)

  /// All-inclusive legacy dependency, with no default components.
  public var legacyDependencyLevel1: LegacyDependency? {
    get { return nil }

    set {
      guard let newValue = newValue else {
        #if DEBUG
        fatalError("Properties cannot be nil")
        #else
        return
        #endif
      }

      let modelDp = RxCalendarLegacy.RegularCalendar.Bridge(self, newValue.0)
      let model = RxCalendarPreset.RegularCalendar.Model(modelDp)
      let viewModel = RxCalendarPreset.RegularCalendar.ViewModel(model)
      dependency = (viewModel, newValue.1)
    }
  }

  /// Only need to implement non-defaultable legacy dependencies. Others will
  /// be provided with defaults.
  public var legacyDependencyLevel2: NoDefaultLegacyDependency? {
    get { return nil }

    set {
      guard let newValue = newValue else {
        #if DEBUG
        fatalError("Properties cannot be nil")
        #else
        return
        #endif
      }

      let modelDp = RxCalendarLegacy.RegularCalendar.Bridge(self, newValue.0)
      let model = RxCalendarPreset.RegularCalendar.Model(modelDp)
      let viewModel = RxCalendarPreset.RegularCalendar.ViewModel(model)
      dependency = (viewModel, newValue.1)
    }
  }
}
