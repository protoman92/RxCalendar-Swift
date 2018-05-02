//
//  MonthControlModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol RxMonthControlModelFunction:
  RxMonthAwareModelFunction,
  RxMonthControlFunction
{
  /// Get the minimum month that we cannot go past.
  var minimumMonth: RxCalendarLogic.Month { get }
  
  /// Get the maximum month that we cannot go past.
  var maximumMonth: RxCalendarLogic.Month { get }
  
  /// Stream the initial month.
  var initialMonthStream: Single<RxCalendarLogic.Month> { get }
}

/// Dependency for month control model.
public protocol RxMonthControlModelDependency: RxMonthControlModelFunction {}

/// Model for month header view.
public protocol RxMonthControlModelType: RxMonthControlModelFunction {}

public extension RxCalendarLogic.MonthControl {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: RxMonthControlModelDependency

    public init(_ dependency: RxMonthControlModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - RxMonthAwareModelFunction
extension RxCalendarLogic.MonthControl.Model: RxMonthAwareModelFunction {
  public var currentMonthStream: Observable<RxCalendarLogic.Month> {
    return dependency.currentMonthStream
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthControl.Model: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return dependency.currentMonthReceiver
  }
}

/// RxMonthControlModelFunction
extension RxCalendarLogic.MonthControl.Model: RxMonthControlModelFunction {
  public var initialMonthStream: Single<RxCalendarLogic.Month> {
    return dependency.initialMonthStream
  }

  public var minimumMonth: RxCalendarLogic.Month {
    return dependency.minimumMonth
  }

  public var maximumMonth: RxCalendarLogic.Month {
    return dependency.maximumMonth
  }
}

// MARK: - RxMonthControlModelType
extension RxCalendarLogic.MonthControl.Model: RxMonthControlModelType {}
