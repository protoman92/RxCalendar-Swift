//
//  Regular99Calendar.swift
//  RxCalendarPreset
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Regular calendar for 99 applications.
public final class RxRegular99Calendar: UIView {
  public typealias Decorator = RxRegular99CalendarDecoratorType
  public typealias ViewModel = RxRegular99CalendarViewModelType
  public typealias Dependency = (ViewModel, Decorator)

  private var monthHeaderId: String {
    return "regular99_monthHeader"
  }

  private var weekdayViewId: String {
    return "regular99_weekdayView"
  }

  private var monthSectionId: String {
    return "regular99_monthSection"
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeViews()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    initializeViews()
  }

  fileprivate var monthHeaderView: RxMonthHeaderView? {
    return subviews.first(where: {$0.accessibilityIdentifier == monthHeaderId})
      as? RxMonthHeaderView
  }

  fileprivate var weekdayView: RxWeekdayView? {
    return subviews.first(where: {$0.accessibilityIdentifier == weekdayViewId})
      as? RxWeekdayView
  }

  fileprivate var monthSectionView: RxMonthSectionView? {
    return subviews.first(where: {$0.accessibilityIdentifier == monthSectionId})
      as? RxMonthSectionView
  }

  private lazy var initialized = false

  private func initializeViews() {
    let monthHeader = RxMonthHeaderView()
    let weekdayLayout = UICollectionViewFlowLayout()
    let sectionLayout = UICollectionViewLayout()

    let weekdayView = RxWeekdayView(frame: CGRect.zero,
                                    collectionViewLayout: weekdayLayout)

    let monthSection = RxMonthSectionView(frame: CGRect.zero,
                                          collectionViewLayout: sectionLayout)

    monthHeader.accessibilityIdentifier = monthHeaderId
    weekdayView.accessibilityIdentifier = weekdayViewId
    monthSection.accessibilityIdentifier = monthSectionId
    addSubview(monthHeader)
    addSubview(weekdayView)
    addSubview(monthSection)

    // Month header constraints
    let allViews = [monthHeaderId : monthHeader,
                    monthSectionId : monthSection,
                    weekdayViewId : weekdayView]

    let verticalConstraintFormat = "V:|"
      + "[\(monthHeaderId)(==\(44))]"
      + "[\(weekdayViewId)(==\(monthHeaderId))]"
      + "[\(monthSectionId)]"
      + "|"

    let monthHeaderHorizontalConstraintFormat = "H:|"
      + "[\(monthHeaderId)]"
      + "|"

    let weekdayViewHorizontalConstraintFormat = "H:|"
      + "[\(weekdayViewId)]"
      + "|"

    let monthSectionHorizontalConstraintFormat = "H:|"
      + "[\(monthSectionId)]"
      + "|"

    translatesAutoresizingMaskIntoConstraints = false
    monthHeader.translatesAutoresizingMaskIntoConstraints = false
    monthSection.translatesAutoresizingMaskIntoConstraints = false
    weekdayView.translatesAutoresizingMaskIntoConstraints = false

    addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: verticalConstraintFormat,
      options: [],
      metrics: nil,
      views: allViews))

    addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: monthHeaderHorizontalConstraintFormat,
      options: [],
      metrics: nil,
      views: allViews))

    addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: weekdayViewHorizontalConstraintFormat,
      options: [],
      metrics: nil,
      views: allViews))

    addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: monthSectionHorizontalConstraintFormat,
      options: [],
      metrics: nil,
      views: allViews))
  }
}

// MARK: - Dependencies
public extension RxRegular99Calendar {
  public var dependency: Dependency? {
    get { return nil }
    set { didSetDependency(newValue) }
  }

  private func didSetDependency(_ dependency: Dependency?) {
    guard
      let dependency = dependency,
      let monthHeader = self.monthHeaderView,
      let monthSection = self.monthSectionView,
      let weekdayView = self.weekdayView else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let vm = dependency.0
    let decorator = dependency.1
    let monthSectionVM = vm.monthSectionViewModel()

    let sectionLayout = RxMonthSectionHorizontalFlowLayout(
      monthSectionVM.totalMonthCount,
      monthSectionVM.weekdayStacks)

    monthSection.collectionViewLayout = sectionLayout
    monthHeader.dependency = (vm.monthHeaderViewModel(), decorator)
    weekdayView.dependency = (vm.selectableWeekdayViewModel(), decorator)
    monthSection.dependency = (monthSectionVM, decorator)
  }
}
