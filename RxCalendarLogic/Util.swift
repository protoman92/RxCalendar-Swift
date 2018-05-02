//
//  Util.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 18/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

// MARK: - Utilities
public extension RxCalendarLogic {

  /// Utilities for calendar views. The date calculators here will be lazily
  /// inialized when some functions are called.
  public final class Util {
    
    /// This will be initialized lazily.
    fileprivate static var defaultCalc: RxCalendarLogic.DateCalc.Default = {
      let weekdayStacks = defaultWeekdayStacks
      let firstWeekday = defaultFirstWeekday
      return RxCalendarLogic.DateCalc.Default(weekdayStacks, firstWeekday)
    }()
    
    /// This will be initialized lazily.
    fileprivate static var highlightCalc: RxCalendarLogic.DateCalc.HighlightPart = {
      let weekdayStacks = defaultWeekdayStacks
      return RxCalendarLogic.DateCalc.HighlightPart(defaultCalc, weekdayStacks)
    }()
  }
}

// MARK: - Default properties
public extension RxCalendarLogic.Util {

  /// Get the number of days in a week.
  public static var weekdayCount: Int { return 7 }
  
  public static var defaultFirstWeekday: Int { return 1 }
  
  /// Get the default weekday stacks.
  public static var defaultWeekdayStacks: Int { return 6 }
}

public extension RxCalendarLogic.Util {
  
  /// Get the default weekday description.
  ///
  /// - Parameter weekday: A weekday value.
  /// - Returns: A String value.
  public static func defaultWeekdayDescription(_ weekday: Int) -> String {
    let date = Calendar.current.date(bySetting: .weekday, value: weekday, of: Date())
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    return date.map({formatter.string(from: $0).uppercased()}).getOrElse("")
  }

  /// Get the default month description.
  ///
  /// - Parameter month: A Month instance.
  /// - Returns: A String value.
  public static func defaultMonthDescription(_ month: RxCalendarLogic.Month) -> String {
    let components = month.dateComponents()
    let date = Calendar.current.date(from: components)!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM yyyy"
    return dateFormatter.string(from: date)
  }

  /// Produce a range of Dates for a Month instance.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstWeekday: The first weekday in a week.
  ///   - weekdayStacks: The number of weekday stacks in a grid.
  /// - Returns: An Array of Date.
  public static func dateRange(_ month: RxCalendarLogic.Month,
                               _ firstWeekday: Int,
                               _ weekdayStacks: Int) -> [Date] {
    let calendar = Calendar.current
    let weekdays = RxCalendarLogic.Util.weekdayCount

    return RxCalendarLogic.Util.firstDateWithWeekday(month, firstWeekday)
      .map({(date: Date) -> [Date] in (0..<weekdayStacks * weekdays).flatMap({
        return calendar.date(byAdding: .day, value: $0, to: date)
      })})
      .getOrElse([])
  }

  /// Calculate the month range between min/max months.
  ///
  /// - Parameters:
  ///   - minMonth: The minimum Month.
  ///   - maxMonth: The maximum Month.
  /// - Returns: An Array of Month.
  public static func monthRange(_ minMonth: RxCalendarLogic.Month,
                                _ maxMonth: RxCalendarLogic.Month) -> [RxCalendarLogic.Month] {
    guard minMonth <= maxMonth else { return [] }
    let monthOffset = maxMonth.monthOffset(from: minMonth)
    return (0...monthOffset).flatMap({minMonth.with(monthOffset: $0)})
  }

  /// Get the total number of months between two months.
  ///
  /// - Parameters:
  ///   - minMonth: The minimum Month.
  ///   - maxMonth: The maximum Month.
  /// - Returns: An Int value.
  public static func monthCount(_ minMonth: RxCalendarLogic.Month,
                                _ maxMonth: RxCalendarLogic.Month) -> Int {
    return Swift.max(maxMonth.monthOffset(from: minMonth) + 1, 0)
  }

  /// Calculate the date in a month/year pair using an offset from the first
  /// date in the grid.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstWeekday: The first weekday in a week.
  ///   - firstDateOffset: The offset from the first date in the grid.
  /// - Returns: A Date instance.
  public static func dateWithOffset(_ month: RxCalendarLogic.Month,
                                    _ firstWeekday: Int,
                                    _ firstDateOffset: Int) -> Date? {
    let calendar = Calendar.current
    
    return RxCalendarLogic.Util.firstDateWithWeekday(month, firstWeekday).flatMap({
      return calendar.date(byAdding: .day, value: firstDateOffset, to: $0)
    })
  }

  /// Calculate the first date in a Month that falls on a certain weekday.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - weekday: An Int value representing a weekday.
  /// - Returns: A Date instance.
  public static func firstDateWithWeekday(_ month: RxCalendarLogic.Month,
                                          _ weekday: Int) -> Date? {
    let calendar = Calendar.current
    let dateComponents = month.dateComponents()

    return calendar.date(from: dateComponents)
      .flatMap({(date: Date) -> Date? in
        let weekdayComp = calendar.component(.weekday, from: date)
        let offset: Int

        if weekdayComp < weekday {
          offset = 7 - (weekday - weekdayComp)
        } else {
          offset = weekdayComp - weekday
        }

        return calendar.date(byAdding: .day, value: -offset, to: date)
      })
  }

  /// Produce a weekday range from a first weekday and a weekday count.
  ///
  /// - Parameters:
  ///   - firstWeekday: The first weekday in a week.
  ///   - weekdayCount: The number of weekdays.
  /// - Returns: An Array of weekdays.
  public static func weekdayRange(_ firstWeekday: Int, _ weekdayCount: Int) -> [Int] {
    return (firstWeekday..<(firstWeekday + weekdayCount))
      .map({$0 % 7}).map({$0 == 0 ? 7 : $0})
  }

  /// Get the weekday that corresponds to an index in a weekday range.
  ///
  /// - Parameter
  ///   - index: The weekday index.
  ///   - firstWeekday: The first weekday in a week.
  /// - Returns: The weekday value.
  public static func weekdayWithIndex(_ index: Int, _ firstWeekday: Int) -> Int {
    let weekday = (index + firstWeekday) % 7
    return weekday == 0 ? 7 : weekday
  }

  /// Provided that this date is selected, check the previous and next dates:
  /// - If the next date is not selected, add a .end part.
  /// - If the previous date is not selected, add a .start part.
  /// - If both the next and previous dates are selected, add a .mid part.
  /// - Otherwise, default to .none.
  ///
  /// - Parameters:
  ///   - selections: The current selections.
  ///   - date: A Date instance.
  /// - Returns: A HighlightPart instance.
  public static func highlightPart(_ selections: Set<RxCalendarLogic.Selection>,
                                   _ date: Date)
    -> RxCalendarLogic.HighlightPart
  {
    guard selections.contains(where: {$0.contains(date)}) else {
      return .none
    }
    
    let calendar = Calendar.current
    var flags: RxCalendarLogic.HighlightPart?

    if
      let nextDate = calendar.date(byAdding: .day, value: 1, to: date),
      !selections.contains(where: {$0.contains(nextDate)})
    {
      flags = flags.map({$0.union(.end)}).getOrElse(.end)
    }

    if
      let prevDate = calendar.date(byAdding: .day, value: -1, to: date),
      !selections.contains(where: {$0.contains(prevDate)})
    {
      flags = flags.map({$0.union(.start)}).getOrElse(.start)
    }

    if
      let prevDate = calendar.date(byAdding: .day, value: -1, to: date),
      let nextDate = calendar.date(byAdding: .day, value: 1, to: date),
      selections.contains(where: {$0.contains(nextDate)}),
      selections.contains(where: {$0.contains(prevDate)})
    {
      flags = .mid
    }

    return flags.getOrElse(.none)
  }

  /// Connect discrete date selections into one continuous string of Dates, by
  /// including dates in between as well. For e.g. we have selections as follows:
  ///
  /// 1/4/2018 - 4/4/2018
  ///
  /// This function will add 2/4/2018 and 3/4/2018 to the selection set. Beware
  /// that the earliest date in the selection will be the anchor, so further
  /// selections, unless even earlier than the previously earliest Date, will
  /// only extend the string.
  ///
  /// - Parameter selection: A Sequence of Date selection.
  /// - Returns: A Set of Date selection.
  public static func connectSelection<S>(_ selection: S) -> Set<Date> where
    S: Sequence, S.Iterator.Element == Date
  {
    guard let min = selection.min(), let max = selection.max() else { return [] }
    let calendar = Calendar.current
    var newSelections = Set<Date>()
    var date: Date? = min
    let compareDay: (Date) -> Bool = {$0 <= max}

    repeat {
      _ = date.map({newSelections.insert($0)})
      date = date.flatMap({calendar.date(byAdding: .day, value: 1, to: $0)})
    } while date.map(compareDay).getOrElse(false)

    return newSelections
  }
}

// MARK: - Date calculations
public extension RxCalendarLogic.Util {
  
  /// Calculate grid selection changes with default date calculators.
  ///
  /// - Parameters:
  ///   - monthComp: The current month comp.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A Set of changed GridPosition.
  public static func defaultGridSelectionChanges(
    _ monthComp: RxCalendarLogic.MonthComp,
    _ prev: Set<RxCalendarLogic.Selection>,
    _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return highlightCalc.gridSelectionChanges(monthComp, prev, current)
  }
  
  /// Calculate grid selection changes with default date calculators.
  ///
  /// - Parameters:
  ///   - monthComps: The array of available month comps.
  ///   - currentMonth: The current month.
  ///   - prev: The previous selections.
  ///   - current: The current selections.
  /// - Returns: A Set of changed GridPosition.
  public static func defaultGridSelectionChanges(
    _ monthComps: [RxCalendarLogic.MonthComp],
    _ currentMonth: RxCalendarLogic.Month,
    _ prev: Set<RxCalendarLogic.Selection>,
    _ current: Set<RxCalendarLogic.Selection>)
    -> Set<RxCalendarLogic.GridPosition>
  {
    return highlightCalc.gridSelectionChanges(monthComps, currentMonth, prev, current)
  }
}
