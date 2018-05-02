//
//  MonthGridModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol RxMonthGridModelFunction: RxGridDisplayFunction {}

/// Dependency for month grid model.
public protocol RxMonthGridModelDependency: RxMonthGridModelFunction {}

/// Model for month grid views.
public protocol RxMonthGridModelType: RxMonthGridModelFunction {}

// MARK: - Model.
public extension RxCalendarLogic.MonthGrid {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: RxMonthGridModelDependency

    required public init(_ dependency: RxMonthGridModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - RxGridDisplayFunction
extension RxCalendarLogic.MonthGrid.Model: RxGridDisplayFunction {
  public var weekdayStacks: Int { return dependency.weekdayStacks }
}

// MARK: - RxMonthGridModelType
extension RxCalendarLogic.MonthGrid.Model: RxMonthGridModelType {}
