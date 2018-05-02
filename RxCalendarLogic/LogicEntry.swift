//
//  LogicEntry.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// This is the entry point to all features, and acts as a namespace to the
/// underlying logic.
public final class RxCalendarLogic {

  /// Represents date calculators.
  public final class DateCalc {}

  /// Represents calculators for date selection highlights. These calculators
  /// will be used mainly with the selection highlight view.
  public final class HighlightCalculator {}

  /// A grid display view is represented by a collection of cells that are laid
  /// down horizontally/vertically, with outliers going to the next row/column.
  public final class GridDisplay {}

  /// Represents views that are aware of the current month, including the week
  /// day selection view (i.e. select a weekday to select all days in a month
  /// with that weekday), the month view and the month section view.
  public final class MonthAware {}

  /// Represents views that can control months, including the month header view
  /// (click backward/forward to go to the previous/next month), the month view
  /// and month section view (both use swipe actions to change current month).
  public final class MonthControl {}

  /// Represents the month header display view. This contains the backward/
  /// forward buttons to driver month selection.
  public final class MonthHeader {}

  /// A month grid is a view that displays the days of a month in a grid-like
  /// structure. For e.g., a convential grid has 7 columns corresponding to 7
  /// days in a week, and 6 rows to contain all days in a month, for a total of
  /// 42 cells. This includes the month view and month section view.
  public final class MonthGrid {}

  /// Represents the month display view. This view is efficient at displaying
  /// calendar dates because it does not need any caching - instead it computes
  /// the dates lazily based on the currently selected month.
  public final class MonthDisplay {}

  /// Represents the month section view. This has the traditional calendar view
  /// feel because the user can swipe left/right to go to other months, but is
  /// heavier in terms of memory usage since it needs to do caching for months
  /// and cell layout attributes.
  public final class MonthSection {}

  /// Represents day selection views, including the month view and month section
  /// view.
  public final class DaySelect {}

  /// Represents views that are weekday-aware, such as the weekday view and
  /// month-grid based views.
  public final class WeekdayAware {}

  /// Represents a view that displays week days.
  public final class WeekdayDisplay {}

  /// Represents a weekday view that allows weekday selection to affect date
  /// selection (e.g. if the user clicks on Monday, all Mondays in the current
  /// month will be selected).
  public final class SelectWeekday {}
}
