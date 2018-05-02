//
//  Selection.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 19/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

// MARK: - Selection.
extension RxCalendarLogic {

  /// Represents a Selection object that determines whether a Date is selected.
  /// We use this Selection object instead of storing the Date directly because
  /// it provides us with the means to create custom selection logic, such as
  /// periodic (weekly/monthly) repetitions, simple selection etc. This is a
  /// concrete class instead of a protocol because some of the protocols it
  /// conforms to requires Self.
  ///
  /// To use this class, we must override all methods that are marked as "open"
  /// below.
  open class Selection: Equatable, Hashable {
    open var hashValue: Int { return 0 }

    /// Override this to cheat Equatable. This approach is similar to NSObject's
    /// isEqual.
    ///
    /// - Parameter selection: A Selection instance.
    /// - Returns: A Bool value.
    open func isSameAs(_ selection: Selection) -> Bool { return true }

    /// Each Selection implementation will have a different mechanism for
    /// determining whether a date is selected. For e.g. the DateSelection
    /// subclass checks selection status by comparing the input Date against
    /// the stored Date, while the RepeatWeekdaySelection may do so by verifying
    /// the Date's weekday to see if it matches the stored weekday.
    ///
    /// - Parameter date: A Date instance.
    /// - Returns: A Bool value.
    open func contains(_ date: Date) -> Bool { return false }

    /// Calculate the associated grid selection in an Array of Month Components.
    /// Consult the documentation for RxGridSelectionCalculator and its subtypes
    /// to understand the purpose of this method.
    ///
    /// We do not pass in the currentMonth and just the currentMonthIndex so
    /// that the selection objects do not need to compute said index again and
    /// again, since there might be many selection objects.
    ///
    /// - Parameter
    ///   - monthComps: A MonthComp Array.
    ///   - currentMonthIndex: The current Month index.
    /// - Returns: A Set of GridPosition.
    open func gridPosition(_ monthComps: [RxCalendarLogic.MonthComp],
                           _ currentMonthIndex: Int)
      -> Set<RxCalendarLogic.GridPosition> { return [] }

    public static func ==(_ lhs: Selection, _ rhs: Selection) -> Bool {
      return lhs.isSameAs(rhs)
    }
  }
}

// MARK: - Date Selection.
public extension RxCalendarLogic {

  /// Store a Date and compare it against the input Date.
  public final class DateSelection: Selection, CustomStringConvertible {
    override public var hashValue: Int { return date.hashValue }
    
    public var description: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd-MMM-yyyy"
      return "Date \(dateFormatter.string(from: date))"
    }
    
    public let date: Date
    private let firstWeekday: Int

    public init(_ date: Date, _ firstWeekday: Int) {
      self.date = date
      self.firstWeekday = firstWeekday
    }

    override public func isSameAs(_ selection: RxCalendarLogic.Selection) -> Bool {
      guard let selection = selection as? DateSelection else { return false }
      return selection.date == date
    }

    override public func contains(_ date: Date) -> Bool {
      return self.date == date
    }

    /// If the date falls out of the current month, don't return anything. This
    /// is for performance reasons.
    override public func gridPosition(_ monthComps: [RxCalendarLogic.MonthComp],
                                      _ monthIndex: Int)
      -> Set<RxCalendarLogic.GridPosition>
    {
      guard
        monthIndex >= 0 && monthIndex < monthComps.count,
        monthComps[monthIndex].contains(date) else
      {
        return []
      }

      let monthComp = monthComps[monthIndex]
      return gridPosition(monthComps, monthComp, monthIndex, date)
    }

    /// Since each Date may be included in different months (e.g., if there are
    /// more than 31 cells, the calendar view may include dates from previous/
    /// next months). To be safe, we calculate the selection for one month before
    /// and after the specified month.
    fileprivate func gridPosition(_ monthComps: [RxCalendarLogic.MonthComp],
                                  _ monthComp: RxCalendarLogic.MonthComp,
                                  _ monthIndex: Int,
                                  _ selection: Date)
      -> Set<RxCalendarLogic.GridPosition>
    {
      let calendar = Calendar.current
      let firstWeekday = self.firstWeekday

      let calculate = {(monthComp: RxCalendarLogic.MonthComp, offset: Int)
        -> RxCalendarLogic.GridPosition? in
        if let fDate = Util.firstDateWithWeekday(monthComp.month, firstWeekday) {
          let diff = calendar.dateComponents([.day], from: fDate, to: selection)

          if let dayDiff = diff.day, dayDiff >= 0 && dayDiff < monthComp.dayCount {
            return RxCalendarLogic.GridPosition(offset, dayDiff)
          }
        }

        return Optional.none
      }

      var gridPositions = Set<RxCalendarLogic.GridPosition>()
      _ = calculate(monthComp, monthIndex).map({gridPositions.insert($0)})
      let prevMonthIndex = monthIndex - 1
      let nextMonthIndex = monthIndex + 1

      if prevMonthIndex >= 0 && prevMonthIndex < monthComps.count {
        let prevMonth = monthComps[prevMonthIndex]
        _ = calculate(prevMonth, prevMonthIndex).map({gridPositions.insert($0)})
      }

      if nextMonthIndex >= 0 && nextMonthIndex < monthComps.count {
        let nextMonth = monthComps[nextMonthIndex]
        _ = calculate(nextMonth, nextMonthIndex).map({gridPositions.insert($0)})
      }

      return gridPositions
    }
  }
}

// MARK: - RepeatWeekdaySelection.
public extension RxCalendarLogic {
  public final class RepeatWeekdaySelection: Selection, CustomStringConvertible {
    public var description: String { return "All dates for weekday \(weekday)" }
    public let weekday: Int
    public let firstWeekday: Int
    private let calendar: Calendar

    public init(_ weekday: Int, _ firstWeekday: Int) {
      self.weekday = weekday
      self.firstWeekday = firstWeekday
      calendar = Calendar.current
    }

    override public func isSameAs(_ selection: RxCalendarLogic.Selection) -> Bool {
      guard let rws = selection as? RepeatWeekdaySelection else { return false }
      return weekday == rws.weekday
    }

    /// As long as the date has the same weekday, consider it contained.
    override public func contains(_ date: Date) -> Bool {
      return calendar.component(.weekday, from: date) == weekday
    }

    /// Since we only need to refresh for the current month, only calculate for
    /// that month.
    override public func gridPosition(_ monthComps: [RxCalendarLogic.MonthComp],
                                      _ monthIndex: Int)
      -> Set<RxCalendarLogic.GridPosition>
    {
      guard
        monthIndex >= 0 && monthIndex < monthComps.count,
        weekday >= firstWeekday else
      {
        return []
      }

      let monthComp = monthComps[monthIndex]
      var positions = Set<RxCalendarLogic.GridPosition>()
      var currentDayIndex = weekday - firstWeekday

      while currentDayIndex < monthComp.dayCount {
        let position = RxCalendarLogic.GridPosition(monthIndex, currentDayIndex)
        positions.insert(position)
        currentDayIndex += 7
      }

      return positions
    }
  }
}
