//
//  Model.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol RxMonthHeaderModelFunction {
  
  /// Format month description.
  ///
  /// - Parameter month: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ month: RxCalendarLogic.Month) -> String
}

/// Dependency for month header model.
public protocol RxMonthHeaderModelDependency:
  RxMonthControlModelDependency,
  RxMonthHeaderModelFunction {}

/// Model for month header view.
public protocol RxMonthHeaderModelType:
  RxMonthControlModelType,
  RxMonthHeaderModelFunction {}

public extension RxCalendarLogic.MonthHeader {

  /// Model implementation.
  public final class Model {
    fileprivate let monthControlModel: RxMonthControlModelType
    fileprivate let dependency: RxMonthHeaderModelDependency

    required public init(_ monthControlModel: RxMonthControlModelType,
                         _ dependency: RxMonthHeaderModelDependency) {
      self.dependency = dependency
      self.monthControlModel = monthControlModel
    }

    convenience public init(_ dependency: RxMonthHeaderModelDependency) {
      let monthControlModel = RxCalendarLogic.MonthControl.Model(dependency)
      self.init(monthControlModel, dependency)
    }
  }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarLogic.MonthHeader.Model: RxMonthAwareModelFunction {
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return monthControlModel.currentMonthStream
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthHeader.Model: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - RxMonthControlModelFunction
extension RxCalendarLogic.MonthHeader.Model: RxMonthControlModelFunction {
  public var initialMonthStream: PrimitiveSequence<SingleTrait, RxCalendarLogic.Month> {
    return monthControlModel.initialMonthStream
  }

  public var minimumMonth: RxCalendarLogic.Month {
    return monthControlModel.minimumMonth
  }

  public var maximumMonth: RxCalendarLogic.Month {
    return monthControlModel.maximumMonth
  }
}

// MARK: - RxMonthHeaderModelFunction
extension RxCalendarLogic.MonthHeader.Model: RxMonthHeaderModelFunction {
  public func formatMonthDescription(_ month: RxCalendarLogic.Month) -> String {
    return dependency.formatMonthDescription(month)
  }
}

// MARK: - RxMonthHeaderModelType
extension RxCalendarLogic.MonthHeader.Model: RxMonthHeaderModelType {}
