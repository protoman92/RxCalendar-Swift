//
//  ViewModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month header view.
public protocol RxMonthHeaderViewModelType: RxMonthControlViewModelType {

  /// Stream month descriptions to populate the month display label.
  var monthDescriptionStream: Observable<String> { get }

  /// Emit an event whenever the user has reached the minimum month.
  var reachedMinimumMonth: Observable<Bool> { get }

  /// Emit an event whenever the user has reached the maximum month.
  var reachedMaximumMonth: Observable<Bool> { get }
}

// MARK: - All bindings.
public extension RxMonthHeaderViewModelType {
  public func setupAllBindingsAndSubBindings() {
    setupMonthControlBindings()
  }
}

/// Factory for month header view model.
public protocol RxMonthHeaderViewModelFactory {

  /// Create a month header view model.
  ///
  /// - Returns: A RxMonthHeaderViewModelType instance.
  func monthHeaderViewModel() -> RxMonthHeaderViewModelType
}

public extension RxCalendarLogic.MonthHeader {
  
  /// View model implementation.
  public final class ViewModel {

    /// Delegate month controlling to this view model.
    fileprivate let monthControlVM: RxMonthControlViewModelType
    fileprivate let model: RxMonthHeaderModelType
    fileprivate let disposable: DisposeBag

    required public init(_ monthControlVM: RxMonthControlViewModelType,
                         _ model: RxMonthHeaderModelType) {
      self.monthControlVM = monthControlVM
      self.model = model
      disposable = DisposeBag()
    }

    convenience public init(_ model: RxMonthHeaderModelType) {
      let monthControlVM = RxCalendarLogic.MonthControl.ViewModel(model)
      self.init(monthControlVM, model)
    }
  }
}

// MARK: - RxMonthControlFunction
extension RxCalendarLogic.MonthHeader.ViewModel: RxMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<RxCalendarLogic.Month> {
    return monthControlVM.currentMonthReceiver
  }
}

// MARK: - RxMonthControlViewModelType
extension RxCalendarLogic.MonthHeader.ViewModel: RxMonthControlViewModelType {
  public var currentMonthForwardReceiver: AnyObserver<Void> {
    return monthControlVM.currentMonthForwardReceiver
  }

  public var currentMonthBackwardReceiver: AnyObserver<Void> {
    return monthControlVM.currentMonthBackwardReceiver
  }

  public func setupMonthControlBindings() {
    monthControlVM.setupMonthControlBindings()
  }
}

// MARK: - RxMonthHeaderViewModelType
extension RxCalendarLogic.MonthHeader.ViewModel: RxMonthHeaderViewModelType {
  public var reachedMinimumMonth: Observable<Bool> {
    let minMonth = model.minimumMonth
    return model.currentMonthStream.map({$0 == minMonth}).distinctUntilChanged()
  }

  public var reachedMaximumMonth: Observable<Bool> {
    let maxMonth = model.maximumMonth
    return model.currentMonthStream.map({$0 == maxMonth}).distinctUntilChanged()
  }

  public var monthDescriptionStream: Observable<String> {
    return model.currentMonthStream
      .map({[weak self] in self?.model.formatMonthDescription($0)})
      .filter({$0.isSome}).map({$0!})
  }
}
