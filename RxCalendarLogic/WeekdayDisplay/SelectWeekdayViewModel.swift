//
//  SelectWeekdayViewModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for selectable weekday display view. This is a decorator over the
/// week display view model.
public protocol RxSelectWeekdayViewModelType: RxWeekdayDisplayViewModelType {}

/// Factory for selectable weekday view model.
public protocol RxSelectWeekdayViewModelFactory {

  /// Create a selectable weekday view model.
  ///
  /// - Returns: A RxSelectableWeekdayViewModelType instance.
  func selectableWeekdayViewModel() -> RxSelectWeekdayViewModelType
}

// MARK: - View model.
public extension RxCalendarLogic.SelectWeekday {

  /// View model implementation.
  public final class ViewModel {
    fileprivate let weekdayVM: RxWeekdayDisplayViewModelType
    fileprivate let model: RxSelectWeekdayModelType
    fileprivate let disposable: DisposeBag

    required public init(_ weekdayVM: RxWeekdayDisplayViewModelType,
                         _ model: RxSelectWeekdayModelType) {
      self.weekdayVM = weekdayVM
      self.model = model
      disposable = DisposeBag()
    }

    convenience public init(_ model: RxSelectWeekdayModelType) {
      let weekdayVM = RxCalendarLogic.WeekdayDisplay.ViewModel(model)
      self.init(weekdayVM, model)
    }
  }
}

// MARK: - RxWeekdayDisplayViewModelType
extension RxCalendarLogic.SelectWeekday.ViewModel: RxWeekdayDisplayViewModelType {
  public var weekdayStream: Observable<[RxCalendarLogic.Weekday]> {
    return weekdayVM.weekdayStream
  }

  public var weekdaySelectionIndexReceiver: AnyObserver<Int> {
    return weekdayVM.weekdaySelectionIndexReceiver
  }

  public var weekdaySelectionStream: Observable<Int> {
    return weekdayVM.weekdaySelectionStream
  }

  public func setupWeekDisplayBindings() {
    weekdayVM.setupWeekDisplayBindings()
    let disposable = self.disposable
    let firstWeekday = model.firstWeekday

    // In case:
    // - The user selects a weekday range (e.g. all Mondays).
    // - The user then deselects a Monday within said weekday range.
    // - The next time they selects the same range, some cells will be selected
    // (i.e. the previously deselected date) while the rest becomes deselected.
    weekdaySelectionStream
      .withLatestFrom(model.currentMonthStream) {($1, $0)}
      .map({$0.datesWithWeekday($1)})
      .map({Set($0.map({RxCalendarLogic.DateSelection($0, firstWeekday)}))})
      .withLatestFrom(model.allSelectionStream) {
        return $1.getOrElse([]).symmetricDifference($0)
      }
      .subscribe(model.allSelectionReceiver)
      .disposed(by: disposable)

//    // Uncomment this (and comment the above binding) to quick-test repeat
//    // weekday selection.
//    weekdaySelectionStream
//      .map({RxCalendarLogic.RepeatWeekdaySelection($0, firstWeekday)})
//      .withLatestFrom(model.allSelectionStream) {
//        return $1.getOrElse([]).symmetricDifference(Set(arrayLiteral: $0))
//      }
//      .subscribe(model.allSelectionReceiver)
//      .disposed(by: disposable)
  }
}

// MARK: - RxSelectableWeekdayViewModelType
extension RxCalendarLogic.SelectWeekday.ViewModel: RxSelectWeekdayViewModelType {}
