//
//  MonthGridViewModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month-grid based views.
public protocol RxMonthGridViewModelType: RxGridDisplayFunction {

  /// Trigger grid item selection. Each grid selection corresponds to an Index
  /// Path in the current month grid.
  var gridSelectionReceiver: AnyObserver<RxCalendarLogic.GridPosition> { get }

  /// Stream grid selections.
  var gridSelectionStream: Observable<RxCalendarLogic.GridPosition> { get }
}

// MARK: - ViewModel.
public extension RxCalendarLogic.MonthGrid {

  /// View model implementation for month grid view.
  public final class ViewModel {
    fileprivate let model: RxMonthGridModelType
    fileprivate let gridSelectionSb: PublishSubject<RxCalendarLogic.GridPosition>

    required public init(_ model: RxMonthGridModelType) {
      self.model = model
      gridSelectionSb = PublishSubject()
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLogic.MonthGrid.ViewModel: RxGridDisplayFunction {
  public var weekdayStacks: Int { return model.weekdayStacks }
}

// MARK: - RxMonthGridViewModelType
extension RxCalendarLogic.MonthGrid.ViewModel: RxMonthGridViewModelType {
  public var gridSelectionStream: Observable<RxCalendarLogic.GridPosition> {
    return gridSelectionSb.asObservable()
  }

  public var gridSelectionReceiver: AnyObserver<RxCalendarLogic.GridPosition> {
    return gridSelectionSb.asObserver()
  }
}
