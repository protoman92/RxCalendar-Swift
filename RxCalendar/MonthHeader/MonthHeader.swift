//
//  MonthHeader.swift
//  RxCalendar
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import InterfaceUtilities
import RxCalendarLogic
import RxSwift
import UIKit

/// Month header view for calendar.
public final class RxMonthHeaderView: UIView {
  public typealias Decorator = RxMonthHeaderDecoratorType
  public typealias ViewModel = RxMonthHeaderViewModelType
  public typealias Dependency = (ViewModel, Decorator)

  fileprivate var backwardImgId: String {
    return "rxcalendar_monthHeader_backwardImg"
  }

  fileprivate var forwardImgId: String {
    return "rxcalendar_monthHeader_forwardImg"
  }

  fileprivate var backwardBtnId: String {
    return "rxcalendar_monthHeader_backwardBtn"
  }

  fileprivate var forwardBtnId: String {
    return "rxcalendar_monthHeader_forwardBtn"
  }

  fileprivate var monthLblId: String {
    return "rxcalendar_monthHeader_monthLbl"
  }

  @IBOutlet fileprivate weak var backwardImg: UIImageView!
  @IBOutlet fileprivate weak var backwardBtn: UIButton!
  @IBOutlet fileprivate weak var forwardImg: UIImageView!
  @IBOutlet fileprivate weak var forwardBtn: UIButton!
  @IBOutlet fileprivate weak var monthLbl: UILabel!

  /// Set all dependencies here.
  public var dependency: Dependency? {
    willSet {
      #if DEBUG
      if dependency != nil {
        fatalError("Cannot mutate!")
      }
      #endif
    }

    didSet {
      bindViewModel()
      setupViewsWithDecorator()
    }
  }
  
  fileprivate var viewModel: ViewModel? { return dependency?.0 }
  fileprivate var decorator: Decorator? { return dependency?.1 }

  fileprivate lazy var disposable: DisposeBag = DisposeBag()
  fileprivate lazy var initialized = false

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    HPViewUtil.initializeWithNib(view: self, nibName: "MonthHeader")
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    HPViewUtil.initializeWithNib(view: self, nibName: "MonthHeader")
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard !initialized,
      backwardImg != nil,
      backwardBtn != nil,
      forwardImg != nil,
      forwardBtn != nil,
      monthLbl != nil else
    {
      return
    }

    initialized = true
    setupViews()
  }
}

// MARK: - Views
public extension RxMonthHeaderView {
  fileprivate func setupViews() {
    let bundle = Bundle(for: RxMonthHeaderView.classForCoder())

    guard
      let backwardImg = self.backwardImg,
      let forwardImg = self.forwardImg,
      let backwardIcon = UIImage(named: "backward", in: bundle, compatibleWith: nil)?
        .withRenderingMode(.alwaysTemplate),
      let backCg = backwardIcon.cgImage else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    /// Flip programmatically to reuse assets.
    let forwardIcon = UIImage(cgImage: backCg, scale: 1, orientation: .down)
      .withRenderingMode(.alwaysTemplate)

    backwardImg.image = backwardIcon
    forwardImg.image = forwardIcon
  }

  fileprivate func setupViewsWithDecorator() {
    guard let decorator = self.decorator, let monthLbl = self.monthLbl else {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    monthLbl.textColor = decorator.monthDescriptionTextColor
    monthLbl.font = decorator.monthDescriptionFont
  }
}

// MARK: - Bindings.
public extension RxMonthHeaderView {

  /// Set up stream bindings.
  fileprivate func bindViewModel() {
    guard
      let viewModel = self.viewModel,
      let decorator = self.decorator,
      let monthLbl = self.monthLbl,
      let backwardBtn = self.backwardBtn,
      let backwardImg = self.backwardImg,
      let forwardBtn = self.forwardBtn,
      let forwardImg = self.forwardImg else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let disposable = self.disposable
    viewModel.setupAllBindingsAndSubBindings()

    let navButtonTint = decorator.navigationButtonTintColor
    let navButtonDisabledTint = decorator.navigationButtonDisabledTintColor
    let reachedMinStream = viewModel.reachedMinimumMonth.share(replay: 1)
    let reachedMaxStream = viewModel.reachedMaximumMonth.share(replay: 1)

    backwardBtn.rx.tap
      .bind(to: viewModel.currentMonthBackwardReceiver)
      .disposed(by: disposable)

    reachedMinStream.map({!$0})
      .observeOn(MainScheduler.instance)
      .bind(to: backwardBtn.rx.isEnabled)
      .disposed(by: disposable)

    reachedMinStream
      .map({$0 ? navButtonDisabledTint : navButtonTint})
      .observeOn(MainScheduler.instance)
      .bind(onNext: {[weak backwardImg] in backwardImg?.tintColor = $0})
      .disposed(by: disposable)

    forwardBtn.rx.tap
      .bind(to: viewModel.currentMonthForwardReceiver)
      .disposed(by: disposable)

    reachedMaxStream.map({!$0})
      .observeOn(MainScheduler.instance)
      .bind(to: forwardBtn.rx.isEnabled)
      .disposed(by: disposable)

    reachedMaxStream
      .map({$0 ? navButtonDisabledTint : navButtonTint})
      .observeOn(MainScheduler.instance)
      .bind(onNext: {[weak forwardImg] in forwardImg?.tintColor = $0})
      .disposed(by: disposable)

    viewModel.monthDescriptionStream
      .observeOn(MainScheduler.instance)
      .bind(to: monthLbl.rx.text)
      .disposed(by: disposable)
  }
}
