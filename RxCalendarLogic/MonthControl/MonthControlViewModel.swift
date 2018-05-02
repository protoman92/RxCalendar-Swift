//
//  MonthControlViewModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for controlling month. This can be used both by the month header
/// (with the forward/backward buttons) and the month view (right/left swipes).
public protocol RxMonthControlViewModelType: RxMonthControlFunction {

  /// Move forward by some months.
  var currentMonthForwardReceiver: AnyObserver<Void> { get }

  /// Move backward by some months.
  var currentMonthBackwardReceiver: AnyObserver<Void> { get }

  /// Set up stream bindings.
  func setupMonthControlBindings()
}

public extension RxCalendarLogic.MonthControl {
  
  /// Month control view model implementation.
  public final class ViewModel {
    fileprivate let disposable: DisposeBag
    fileprivate let currentMonthMovementSb: PublishSubject<MonthDirection>
    fileprivate let model: RxMonthControlModelType

    public init(_ model: RxMonthControlModelType) {
      self.model = model
      disposable = DisposeBag()
      currentMonthMovementSb = PublishSubject()
    }
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthControl.ViewModel: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return model.currentMonthReceiver
  }
}

// MARK: - RxMonthControlViewModelType
extension RxCalendarLogic.MonthControl.ViewModel: RxMonthControlViewModelType {
  public var currentMonthForwardReceiver: AnyObserver<Void> {
    return currentMonthMovementSb.mapObserver({MonthDirection.forward(1)})
  }

  public var currentMonthBackwardReceiver: AnyObserver<Void> {
    return currentMonthMovementSb.mapObserver({MonthDirection.backward(1)})
  }

  public func setupMonthControlBindings() {
    let disposable = self.disposable
    let minMonth = model.minimumMonth
    let maxMonth = model.maximumMonth

    Observable
      .merge(
        model.initialMonthStream.asObservable(),

        currentMonthMovementSb
          .withLatestFrom(model.currentMonthStream) {($1, $0.monthOffset)}
          .map({$0.with(monthOffset: $1)})
          .filter({$0.isSome}).map({$0!})
      )
      .map({Swift.min(maxMonth, Swift.max(minMonth, $0))})
      .subscribe(model.currentMonthReceiver)
      .disposed(by: disposable)
  }
}
