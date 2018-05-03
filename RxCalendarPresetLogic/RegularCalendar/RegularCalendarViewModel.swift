//
//  RegularCalendarViewModel.swift
//  RxCalendarPresetLogic
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// View model for RegularCalendar preset. Note that this view model only extends
/// from factory protocols - this is because each component view model could
/// have its own state, so it's unwise to let this view model implement all
/// their features. This is different from the preset model (which implements
/// all component features) because the model itself does not carry any state
/// operations, and thus is just a collection of dependencies and pure functions.
public protocol RxRegularCalendarViewModelType:
  RxMonthHeaderViewModelFactory,
  RxMonthSectionViewModelFactory,
  RxSelectWeekdayViewModelFactory {}

// MARK: - ViewModel
public extension RxCalendarPreset.RegularCalendar {

  /// View model implementation for RegularCalendar preset.
  public final class ViewModel {
    fileprivate let model: RxRegularCalendarModelType

    required public init(_ model: RxRegularCalendarModelType) {
      self.model = model
    }
  }
}

// MARK: - RxMonthHeaderViewModelFactory
extension RxCalendarPreset.RegularCalendar.ViewModel: RxMonthHeaderViewModelFactory {
  public func monthHeaderViewModel() -> RxMonthHeaderViewModelType {
    return RxCalendarLogic.MonthHeader.ViewModel(model)
  }
}

// MARK: - RxMonthSectionViewModelFactory
extension RxCalendarPreset.RegularCalendar.ViewModel: RxMonthSectionViewModelFactory {
  public func monthSectionViewModel() -> RxMonthSectionViewModelType {
    return RxCalendarLogic.MonthSection.ViewModel(model)
  }
}

// MARK: - RxSelectWeekdayViewModelFactory
extension RxCalendarPreset.RegularCalendar.ViewModel: RxSelectWeekdayViewModelFactory {
  public func selectableWeekdayViewModel() -> RxSelectWeekdayViewModelType {
    return RxCalendarLogic.SelectWeekday.ViewModel(model)
  }
}

// MARK: - RxRegularCalendarViewModelType
extension RxCalendarPreset.RegularCalendar.ViewModel: RxRegularCalendarViewModelType {}
