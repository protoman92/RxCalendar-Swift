//
//  WeekdayDisplayViewModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for weekday display view.
public protocol RxWeekdayDisplayViewModelType {
  /// Stream weekdays.
  var weekdayStream: Observable<[RxCalendarLogic.Weekday]> { get }

  /// Receive weekday selection indexes. Beware that this is 0-based so we need
  /// to add 1 to get the actual weekday.
  var weekdaySelectionIndexReceiver: AnyObserver<Int> { get }

  /// Stream weekday selections.
  var weekdaySelectionStream: Observable<Int> { get }

  /// Set up week display bindings.
  func setupWeekDisplayBindings()
}

// MARK: - View model.
public extension RxCalendarLogic.WeekdayDisplay {
  public final class ViewModel {
    fileprivate let model: RxWeekdayDisplayModelType
    fileprivate let selectionSb: PublishSubject<Int>

    required public init(_ model: RxWeekdayDisplayModelType) {
      self.model = model
      selectionSb = PublishSubject()
    }
  }
}

// MARK: - RxWeekdayDisplayViewModelType
extension RxCalendarLogic.WeekdayDisplay.ViewModel: RxWeekdayDisplayViewModelType {
  public var weekdayStream: Observable<[RxCalendarLogic.Weekday]> {
    let firstWeekday = model.firstWeekday
    let weekdayCount = RxCalendarLogic.Util.weekdayCount

    let weekdays = RxCalendarLogic.Util.weekdayRange(firstWeekday, weekdayCount)
      .map({(weekday: $0, description: model.weekdayDescription($0))})
      .map({RxCalendarLogic.Weekday($0.weekday, $0.description)})

    return Observable.just(weekdays)
  }

  public var weekdaySelectionIndexReceiver: AnyObserver<Int> {
    return selectionSb.asObserver()
  }

  /// Since we only receive the weekday selection index, add the firstWeekday
  /// and mod by 8 to get the actual weekday.
  public var weekdaySelectionStream: Observable<Int> {
    let firstWeekday = model.firstWeekday
    return selectionSb.map({RxCalendarLogic.Util.weekdayWithIndex($0, firstWeekday)})
  }

  public func setupWeekDisplayBindings() {}
}
