//
//  Singleton.swift
//  RxCalendarDemo
//
//  Created by Hai Pham on 18/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import RxCalendarLogic
import RxCalendarPresetLogic
import RxCalendarRedux
import RxSwift
import SwiftFP

public final class Singleton {
  public static let instance = Singleton()

  public let reduxStore: RxTreeStore<Any>

  private init() {
    reduxStore = RxTreeStore<Any>.createInstance({
      switch $1 {
      case let action as RxCalendarRedux.Calendar.Action:
        return RxCalendarRedux.Calendar.Reducer.reduce($0, action)

      default:
        fatalError(String(describing: $1))
      }
    })
  }
}

// MARK: - RxGridDisplayFunction
extension Singleton: RxGridDisplayFunction {
  public var weekdayStacks: Int {
    return RxCalendarLogic.Util.defaultWeekdayStacks
  }
}

// MARK: - RxRegularCalendarModelDependency
extension Singleton: RxRegularCalendarModelDependency {
  public var firstWeekday: Int { return 1 }
  
  public var initialMonthStream: Single<RxCalendarLogic.Month> {
    return Single.just(RxCalendarLogic.Month(1, 1970))
  }
  
  public var minimumMonth: RxCalendarLogic.Month {
    return RxCalendarLogic.Month(4, 2018)
  }
  
  public var maximumMonth: RxCalendarLogic.Month {
    return RxCalendarLogic.Month(10, 2018)
  }

  public var allSelectionReceiver: AnyObserver<Set<RxCalendarLogic.Selection>> {
    let actionFn = RxCalendarRedux.Calendar.Action.updateSelection
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }
  
  public var allSelectionStream: Observable<Try<Set<RxCalendarLogic.Selection>>> {
    let path = RxCalendarRedux.Calendar.Action.selectionPath
    return reduxStore.stateValueStream(Set<RxCalendarLogic.Selection>.self, path)
  }
  
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    let path = RxCalendarRedux.Calendar.Action.currentMonthPath
    
    return reduxStore
      .stateValueStream(RxCalendarLogic.Month.self, path)
      .filter({$0.isSuccess}).map({$0.value!})
  }
  
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    let actionFn = RxCalendarRedux.Calendar.Action.updateCurrentMonth
    return reduxStore.actionTrigger().mapObserver(actionFn)
  }
  
  public func isDateSelected(_ date: Date) -> Bool {
    let path = RxCalendarRedux.Calendar.Action.selectionPath
    
    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<RxCalendarLogic.Selection>.self)
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }
  
  public func highlightPart(_ date: Date) -> RxCalendarLogic.HighlightPart {
    let path = RxCalendarRedux.Calendar.Action.selectionPath
    
    return reduxStore
      .lastState.flatMap({$0.stateValue(path)})
      .cast(Set<RxCalendarLogic.Selection>.self)
      .map({RxCalendarLogic.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
  
  public func formatMonthDescription(_ month: RxCalendarLogic.Month) -> String {
    return RxCalendarLogic.Util.defaultMonthDescription(month)
  }
  
  public func gridSelectionChanges(_ monthComps: [RxCalendarLogic.MonthComp],
                                   _ currentMonth: RxCalendarLogic.Month,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return RxCalendarLogic.Util
      .defaultGridSelectionChanges(monthComps, currentMonth, prev, current)
  }
  
  public func weekdayDescription(_ weekday: Int) -> String {
    return RxCalendarLogic.Util.defaultWeekdayDescription(weekday)
  }
}

// MARK: - RxMonthDisplayModelDependency
extension Singleton: RxMonthDisplayModelDependency {
  public func gridSelectionChanges(_ monthComp: RxCalendarLogic.MonthComp,
                                   _ prev: Set<RxCalendarLogic.Selection>,
                                   _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return RxCalendarLogic.Util
      .defaultGridSelectionChanges(monthComp, prev, current)
  }
}
