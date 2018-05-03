//
//  Regular99ViewModel.swift
//  RxCalendarPresetLogic
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// View model for Regular99 preset. Note that this view model only extends
/// from factory protocols - this is because each component view model could
/// have its own state, so it's unwise to let this view model implement all
/// their features. This is different from the preset model (which implements
/// all component features) because the model itself does not carry any state
/// operations, and thus is just a collection of dependencies and pure functions.
public protocol RxRegular99CalendarViewModelType:
  RxMonthHeaderViewModelFactory,
  RxMonthSectionViewModelFactory,
  RxSelectWeekdayViewModelFactory {}

// MARK: - ViewModel
public extension RxCalendarPreset.Regular99 {

  /// View model implementation for Regular99 preset.
  public final class ViewModel {
    fileprivate let model: RxRegular99CalendarModelType

    required public init(_ model: RxRegular99CalendarModelType) {
      self.model = model
    }
  }
}

// MARK: - RxMonthHeaderViewModelFactory
extension RxCalendarPreset.Regular99.ViewModel: RxMonthHeaderViewModelFactory {
  public func monthHeaderViewModel() -> RxMonthHeaderViewModelType {
    return RxCalendarLogic.MonthHeader.ViewModel(model)
  }
}

// MARK: - RxMonthSectionViewModelFactory
extension RxCalendarPreset.Regular99.ViewModel: RxMonthSectionViewModelFactory {
  public func monthSectionViewModel() -> RxMonthSectionViewModelType {
    return RxCalendarLogic.MonthSection.ViewModel(model)
  }
}

// MARK: - RxSelectWeekdayViewModelFactory
extension RxCalendarPreset.Regular99.ViewModel: RxSelectWeekdayViewModelFactory {
  public func selectableWeekdayViewModel() -> RxSelectWeekdayViewModelType {
    return RxCalendarLogic.SelectWeekday.ViewModel(model)
  }
}

// MARK: - RxRegular99CalendarViewModelType
extension RxCalendarPreset.Regular99.ViewModel: RxRegular99CalendarViewModelType {}
