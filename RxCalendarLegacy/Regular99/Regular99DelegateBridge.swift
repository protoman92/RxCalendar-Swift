//
//  Regular99DelegateBridge.swift
//  RxCalendarLegacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarLogic
import RxCalendarPresetLogic
import RxCalendarPreset
import RxSwift
import SwiftFP

// MARK: - Delegate bridge.
extension RxCalendarLegacy.Regular99 {

  /// Delegate bridge for Regular99 calendar preset.
  final class Bridge {
    fileprivate weak var calendar: RxRegular99Calendar?
    fileprivate let delegate: RxRegular99CalendarDelegate?
    fileprivate let currentMonthSb: BehaviorSubject<Void>
    fileprivate let selectionSb: BehaviorSubject<Void>

    private init(_ delegate: RxRegular99CalendarDelegate) {
      self.delegate = delegate
      currentMonthSb = BehaviorSubject(value: ())
      selectionSb = BehaviorSubject(value: ())
    }

    convenience init(_ calendar: RxRegular99Calendar,
                     _ delegate: RxRegular99CalendarDelegate) {
      self.init(Wrapper(delegate))
      self.calendar = calendar
    }

    convenience init(_ calendar: RxRegular99Calendar,
                     _ delegate: RxRegular99CalendarNoDefaultDelegate) {
      self.init(DefaultDelegate(delegate))
      self.calendar = calendar
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLegacy.Regular99.Bridge: RxGridDisplayFunction {
  var weekdayStacks: Int {
    return calendar.zipWith(delegate, {$1.weekdayStacks(for: $0)}).getOrElse(0)
  }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarLegacy.Regular99.Bridge: RxMonthAwareModelFunction {
  var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return currentMonthSb
      .map({[weak self] in (self?.calendar)
        .zipWith(self?.delegate, {$1.currentMonth(for: $0)})
        .flatMap({$0})})
      .filter({$0.isSome}).map({$0!})
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLegacy.Regular99.Bridge: RxMonthControlFunction {
  var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return currentMonthSb.mapObserver({[weak self] month -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99($0, currentMonthChanged: month)
      })
    })
  }
}

// MARK: - RxMonthControlModelFunction
extension RxCalendarLegacy.Regular99.Bridge: RxMonthControlModelFunction {
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
extension RxCalendarLegacy.Regular99.Bridge: RxMonthHeaderModelFunction {
  func formatMonthDescription(_ month: RxCalendarLogic.Month) -> String {
    return calendar
      .zipWith(delegate, {$1.regular99($0, monthDescriptionFor: month)})
      .getOrElse("")
  }
}

// MARK: - RxMultiDaySelectionFunction
extension RxCalendarLegacy.Regular99.Bridge: RxMultiDaySelectionFunction {
  var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    return selectionSb.mapObserver({[weak self] selection -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99($0, selectionChanged: selection)
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
extension RxCalendarLegacy.Regular99.Bridge: RxMultiMonthGridSelectionCalculator {
  func gridSelectionChanges(_ monthComps: [RxCalendarLogic.MonthComp],
                            _ currentMonth: RxCalendarLogic.Month,
                            _ prev: Set<RxCalendarLogic.Selection>,
                            _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return calendar
      .zipWith(delegate, {
        $1.regular99($0, gridSelectionChangesFor: monthComps,
                     whileCurrentMonthIs: currentMonth,
                     withPreviousSelection: prev,
                     andCurrentSelection: current)})
      .getOrElse([])
  }
}

// MARK: - RxSelectHighlightFunction
extension RxCalendarLegacy.Regular99.Bridge: RxSelectHighlightFunction {
  func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    return calendar
      .zipWith(delegate, {$1.regular99($0, highlightPartFor: date)})
      .getOrElse(.none)
  }
}

// MARK: - RxSingleDaySelectionFunction
extension RxCalendarLegacy.Regular99.Bridge: RxSingleDaySelectionFunction {
  func isDateSelected(_ date: Date) -> Bool {
    return calendar
      .zipWith(delegate, {$1.regular99($0, isDateSelected: date)})
      .getOrElse(false)
  }
}

// MARK: - RxWeekdayAwareModelFunction
extension RxCalendarLegacy.Regular99.Bridge: RxWeekdayAwareModelFunction {
  var firstWeekday: Int {
    return calendar.zipWith(delegate, {$1.firstWeekday(for: $0)}).getOrElse(1)
  }
}

// MARK: - RxWeekdayDisplayModelFunction
extension RxCalendarLegacy.Regular99.Bridge: RxWeekdayDisplayModelFunction {
  func weekdayDescription(_ weekday: Int) -> String {
    return calendar
      .zipWith(delegate, {$1.regular99($0, weekdayDescriptionFor: weekday)})
      .getOrElse("")
  }
}

// MARK: - RxRegular99CalendarModelDependency
extension RxCalendarLegacy.Regular99.Bridge: RxRegular99CalendarModelDependency {}

// MARK: - Delegate wrapper.
extension RxCalendarLegacy.Regular99.Bridge {

  /// Wrapper for delegate to store reference weakly. This is because we need
  /// to store a strong reference to the delegate in the bridge class to cater
  /// to default dependencies.
  final class Wrapper: RxRegular99CalendarDelegate {
    private weak var delegate: RxRegular99CalendarDelegate?

    init(_ delegate: RxRegular99CalendarDelegate) {
      self.delegate = delegate
    }

    /// Defaultable.
    func firstWeekday(for calendar: RxRegular99Calendar) -> Int {
      return delegate?.firstWeekday(for: calendar) ?? 1
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   weekdayDescriptionFor weekday: Int) -> String {
      return delegate?.regular99(calendar, weekdayDescriptionFor: weekday) ?? ""
    }

    func weekdayStacks(for calendar: RxRegular99Calendar) -> Int {
      return delegate?.weekdayStacks(for: calendar) ?? 0
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   monthDescriptionFor month: RxCalendarLogic.Month) -> String {
      return RxCalendarLogic.Util.defaultMonthDescription(month)
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   gridSelectionChangesFor months: [RxCalendarLogic.MonthComp],
                   whileCurrentMonthIs month: RxCalendarLogic.Month,
                   withPreviousSelection prev: Set<RxCalendarLogic.Selection>,
                   andCurrentSelection current: Set<RxCalendarLogic.Selection>)
      -> Set<RxCalendarLogic.GridPosition>
    {
      return delegate?.regular99(calendar,
                                 gridSelectionChangesFor: months,
                                 whileCurrentMonthIs: month,
                                 withPreviousSelection: prev,
                                 andCurrentSelection: current) ?? []
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
      return delegate
        .map({$0.minimumMonth(for: calendar)})
        .getOrElse(RxCalendarLogic.Month(Date()))
    }

    func maximumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
      return delegate
        .map({$0.maximumMonth(for: calendar)})
        .getOrElse(RxCalendarLogic.Month(Date()))
    }

    func initialMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
      return delegate
        .map({$0.initialMonth(for: calendar)})
        .getOrElse(RxCalendarLogic.Month(Date()))
    }

    func currentMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month? {
      return delegate?.currentMonth(for: calendar)
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   currentMonthChanged month: RxCalendarLogic.Month) {
      delegate?.regular99(calendar, currentMonthChanged: month)
    }

    func currentSelections(for calendar: RxRegular99Calendar) -> Set<RxCalendarLogic.Selection>? {
      return delegate?.currentSelections(for: calendar) ?? []
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   selectionChanged selections: Set<RxCalendarLogic.Selection>) {
      delegate?.regular99(calendar, selectionChanged: selections)
    }

    func regular99(_ calendar: RxRegular99Calendar, isDateSelected date: Date) -> Bool {
      return delegate?.regular99(calendar, isDateSelected: date) ?? false
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   highlightPartFor date: Date) -> RxCalendarLogic.HighlightPart {
      return delegate?.regular99(calendar, highlightPartFor: date) ?? .none
    }
  }
}

// MARK: - Default delegate
extension RxCalendarLegacy.Regular99.Bridge {

  /// This default delegate also includes embedded storage for current month
  /// and selections, all of which are guarded by a lock for concurrent access.
  /// As a result, using these defaults will dramatically reduce the number of
  /// methods to be implemented by a delegate.
  final class DefaultDelegate: RxRegular99CalendarDelegate {
    private weak var delegate: RxRegular99CalendarNoDefaultDelegate?
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

    init(_ delegate: RxRegular99CalendarNoDefaultDelegate) {
      self.delegate = delegate
      let weekdayStacks = 6
      let sequentialCalc = RxCalendarLogic.DateCalc.Default(weekdayStacks, 1)
      highlightCalc = RxCalendarLogic.DateCalc.HighlightPart(sequentialCalc, weekdayStacks)
      lock = NSLock()
    }

    /// Defaultable.
    func firstWeekday(for calendar: RxRegular99Calendar) -> Int {
      return 1
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   weekdayDescriptionFor weekday: Int) -> String {
      return RxCalendarLogic.Util.defaultWeekdayDescription(weekday)
    }

    func weekdayStacks(for calendar: RxRegular99Calendar) -> Int {
      return highlightCalc.weekdayStacks
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   monthDescriptionFor month: RxCalendarLogic.Month) -> String {
      return RxCalendarLogic.Util.defaultMonthDescription(month)
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   gridSelectionChangesFor months: [RxCalendarLogic.MonthComp],
                   whileCurrentMonthIs month: RxCalendarLogic.Month,
                   withPreviousSelection prev: Set<RxCalendarLogic.Selection>,
                   andCurrentSelection current: Set<RxCalendarLogic.Selection>)
      -> Set<RxCalendarLogic.GridPosition>
    {
      return highlightCalc.gridSelectionChanges(months, month, prev, current)
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
      return delegate?.minimumMonth(for: calendar) ?? RxCalendarLogic.Month(Date())
    }

    func maximumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
      return delegate?.maximumMonth(for: calendar) ?? RxCalendarLogic.Month(Date())
    }

    func initialMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month {
      return delegate?.initialMonth(for: calendar) ?? RxCalendarLogic.Month(Date())
    }

    func currentMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month? {
      return currentMonth
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   currentMonthChanged month: RxCalendarLogic.Month) {
      currentMonth = month
      delegate?.regular99(calendar, currentMonthChanged: month)
    }

    func currentSelections(for calendar: RxRegular99Calendar) -> Set<RxCalendarLogic.Selection>? {
      return currentSelections
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   selectionChanged selections: Set<RxCalendarLogic.Selection>) {
      currentSelections = selections
      delegate?.regular99(calendar, selectionChanged: selections)
    }

    func regular99(_ calendar: RxRegular99Calendar, isDateSelected date: Date) -> Bool {
      return currentSelections
        .map({$0.contains(where: {$0.contains(date)})})
        .getOrElse(false)
    }

    func regular99(_ calendar: RxRegular99Calendar,
                   highlightPartFor date: Date) -> RxCalendarLogic.HighlightPart {
      return currentSelections
        .map({RxCalendarLogic.Util.highlightPart($0, date)})
        .getOrElse(.none)
    }
  }
}

// MARK: - Delegate bridge
public extension RxRegular99Calendar {
  public typealias NoDefaultDelegate = RxRegular99CalendarNoDefaultDelegate
  public typealias Delegate = RxRegular99CalendarDelegate
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

      let modelDp = RxCalendarLegacy.Regular99.Bridge(self, newValue.0)
      let model = RxCalendarPreset.Regular99.Model(modelDp)
      let viewModel = RxCalendarPreset.Regular99.ViewModel(model)
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

      let modelDp = RxCalendarLegacy.Regular99.Bridge(self, newValue.0)
      let model = RxCalendarPreset.Regular99.Model(modelDp)
      let viewModel = RxCalendarPreset.Regular99.ViewModel(model)
      dependency = (viewModel, newValue.1)
    }
  }
}
