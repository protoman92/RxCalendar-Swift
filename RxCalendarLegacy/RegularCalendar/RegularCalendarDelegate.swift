//
//  RegularCalendarDelegate.swift
//  RxCalendarLegacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
import RxSwift

/// Defaultable delegate for RegularCalendar calendar.
public protocol RxRegularCalendarDefaultDelegate: class {

  /// Get the first weekday.
  ///
  /// - Parameter calendar: A RxRegularCalendar instance.
  /// - Returns: An Int value.
  func firstWeekday(for calendar: RxRegularCalendar) -> Int

  /// Get the description for a weekday.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegularCalendar instance.
  ///   - weekday: A weekday value.
  /// - Returns: A String value.
  func regularCalendar(_ calendar: RxRegularCalendar,
                       weekdayDescriptionFor weekday: Int) -> String

  /// Get the weekday stack count.
  ///
  /// - Parameter calendar: A RxRegularCalendar instance.
  /// - Returns: An Int value.
  func weekdayStacks(for calendar: RxRegularCalendar) -> Int

  /// Get the description for a month.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegularCalendar instance.
  ///   - month: A Month instance.
  /// - Returns: A String value.
  func regularCalendar(_ calendar: RxRegularCalendar,
                       monthDescriptionFor month: RxCalendarLogic.Month) -> String

  /// Calculate grid selection changes when the selection changes.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegularCalendar instance.
  ///   - months: An Array of MonthComp.
  ///   - month: A Month instance.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A Set of GridPosition.
  func regularCalendar(_ calendar: RxRegularCalendar,
                       gridSelectionChangesFor months: [RxCalendarLogic.MonthComp],
                       whileCurrentMonthIs month: RxCalendarLogic.Month,
                       withPreviousSelection prev: Set<RxCalendarLogic.Selection>,
                       andCurrentSelection current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>

  /// Check if a Date is selected.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegularCalendar instance.
  ///   - date: A Date instance.
  /// - Returns: A Bool value.
  func regularCalendar(_ calendar: RxRegularCalendar,
                       isDateSelected date: Date) -> Bool

  /// Get the current month.
  ///
  /// - Parameter calendar: A RxRegularCalendar instance.
  /// - Returns: A Month instance.
  func currentMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month?

  /// Get the current selection set.
  ///
  /// - Parameter calendar: A RxRegularCalendar instance.
  /// - Returns: A Set of Selection.
  func currentSelections(for calendar: RxRegularCalendar) -> Set<RxCalendarLogic.Selection>?

  /// Calculate highlight part for a Date.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegularCalendar instance.
  ///   - date: A Date instance.
  /// - Returns: A HighlightPart instance.
  func regularCalendar(_ calendar: RxRegularCalendar,
                       highlightPartFor date: Date) -> RxCalendarLogic.HighlightPart
}

/// Non-defaultable delegate for RegularCalendar calendar.
public protocol RxRegularCalendarNoDefaultDelegate: class {

  /// Get the minimum month.
  ///
  /// - Parameter calendar: A RxRegularCalendar instance.
  /// - Returns: A Month instance.
  func minimumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month

  /// Get the maximum month.
  ///
  /// - Parameter calendar: A RxRegularCalendar instance.
  /// - Returns: A Month instance.
  func maximumMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month

  /// Get the initial month.
  ///
  /// - Parameter calendar: A RxRegularCalendar instance.
  /// - Returns: A Month instance.
  func initialMonth(for calendar: RxRegularCalendar) -> RxCalendarLogic.Month

  /// Trigger callback when the current month changed. Ideally we should store
  /// this month externally.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegularCalendar instance.
  ///   - month: A Month instance.
  func regularCalendar(_ calendar: RxRegularCalendar,
                       currentMonthChanged month: RxCalendarLogic.Month)

  /// Trigger callback when the selection changes. Ideally we should store this
  /// so that we can access later.
  ///
  /// - Parameters:
  ///   - calendar: A RxRegularCalendar instance.
  ///   - selections: A Set of Selection.
  func regularCalendar(_ calendar: RxRegularCalendar,
                       selectionChanged selections: Set<RxCalendarLogic.Selection>)
}

/// Delegate for RegularCalendar calendar.
public protocol RxRegularCalendarDelegate:
  RxRegularCalendarDefaultDelegate,
  RxRegularCalendarNoDefaultDelegate {}
