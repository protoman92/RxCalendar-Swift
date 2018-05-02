//
//  SingleDaySelectionFunction.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and view model.
public protocol RxSingleDaySelectionFunction {

  /// Check if a date is selected. The application running the calendar view
  /// should have a cache of selected dates that it can query, for e.g. in a
  /// BehaviorSubject.
  ///
  /// Although this is an unfortunate escape from the Observable monad, it is
  /// necessary due to performance reasons. If we were to stick fully to
  /// reactive, we would need to store Days within a MonthComp such that every
  /// time a Date is selected, we flip the flag on that Day and push a new set
  /// of data to the month view/section view. I have tried this approach and
  /// seen that performance suffers, esp. with large number of Months.
  ///
  /// - Parameter date: A Date instance.
  /// - Returns: A Bool value.
  func isDateSelected(_ date: Date) -> Bool
}
