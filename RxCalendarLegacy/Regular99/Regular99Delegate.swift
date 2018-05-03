//
//  Regular99Delegate.swift
//  RxCalendarLegacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
import RxSwift

/// Defaultable delegate for Regular99 calendar.
public protocol RxRegular99CalendarDefaultDelegate: class {

  /// Get the first weekday.
  ///
  /// - Parameter calendar: A RxRegular99Calendar instance.
  /// - Returns: An Int value.
  func firstWeekday(for calendar: RxRegular99Calendar) -> Int

  /// Get the description for a weekday.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegular99Calendar instance.
  ///   - weekday: A weekday value.
  /// - Returns: A String value.
  func regular99(_ calendar: RxRegular99Calendar,
                 weekdayDescriptionFor weekday: Int) -> String

  /// Get the weekday stack count.
  ///
  /// - Parameter calendar: A RxRegular99Calendar instance.
  /// - Returns: An Int value.
  func weekdayStacks(for calendar: RxRegular99Calendar) -> Int

  /// Get the description for a month.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegular99Calendar instance.
  ///   - month: A Month instance.
  /// - Returns: A String value.
  func regular99(_ calendar: RxRegular99Calendar,
                 monthDescriptionFor month: RxCalendarLogic.Month) -> String

  /// Calculate grid selection changes when the selection changes.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegular99Calendar instance.
  ///   - months: An Array of MonthComp.
  ///   - month: A Month instance.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A Set of GridPosition.
  func regular99(_ calendar: RxRegular99Calendar,
                 gridSelectionChangesFor months: [RxCalendarLogic.MonthComp],
                 whileCurrentMonthIs month: RxCalendarLogic.Month,
                 withPreviousSelection prev: Set<RxCalendarLogic.Selection>,
                 andCurrentSelection current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>

  /// Check if a Date is selected.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegular99Calendar instance.
  ///   - date: A Date instance.
  /// - Returns: A Bool value.
  func regular99(_ calendar: RxRegular99Calendar,
                 isDateSelected date: Date) -> Bool

  /// Get the current month.
  ///
  /// - Parameter calendar: A RxRegular99Calendar instance.
  /// - Returns: A Month instance.
  func currentMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month?

  /// Get the current selection set.
  ///
  /// - Parameter calendar: A RxRegular99Calendar instance.
  /// - Returns: A Set of Selection.
  func currentSelections(for calendar: RxRegular99Calendar) -> Set<RxCalendarLogic.Selection>?

  /// Calculate highlight part for a Date.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegular99Calendar instance.
  ///   - date: A Date instance.
  /// - Returns: A HighlightPart instance.
  func regular99(_ calendar: RxRegular99Calendar,
                 highlightPartFor date: Date) -> RxCalendarLogic.HighlightPart
}

/// Non-defaultable delegate for Regular99 calendar.
public protocol RxRegular99CalendarNoDefaultDelegate: class {

  /// Get the minimum month.
  ///
  /// - Parameter calendar: A RxRegular99Calendar instance.
  /// - Returns: A Month instance.
  func minimumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month

  /// Get the maximum month.
  ///
  /// - Parameter calendar: A RxRegular99Calendar instance.
  /// - Returns: A Month instance.
  func maximumMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month

  /// Get the initial month.
  ///
  /// - Parameter calendar: A RxRegular99Calendar instance.
  /// - Returns: A Month instance.
  func initialMonth(for calendar: RxRegular99Calendar) -> RxCalendarLogic.Month

  /// Trigger callback when the current month changed. Ideally we should store
  /// this month externally.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegular99Calendar instance.
  ///   - month: A Month instance.
  func regular99(_ calendar: RxRegular99Calendar,
                 currentMonthChanged month: RxCalendarLogic.Month)

  /// Trigger callback when the selection changes. Ideally we should store this
  /// so that we can access later.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegular99Calendar instance.
  ///   - selections: A Set of Selection.
  func regular99(_ calendar: RxRegular99Calendar,
                 selectionChanged selections: Set<RxCalendarLogic.Selection>)
}

/// Delegate for Regular99 calendar.
public protocol RxRegular99CalendarDelegate:
  RxRegular99CalendarDefaultDelegate,
  RxRegular99CalendarNoDefaultDelegate {}
