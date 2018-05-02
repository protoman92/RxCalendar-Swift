//
//  ViewController.swift
//  RxCalendarDemo
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendar
import RxCalendarLogic
import RxCalendarRedux
import RxSwift
import SwiftFP
import UIKit

public final class ViewController: UIViewController  {
  @IBOutlet fileprivate weak var weekdayView: RxWeekdayView!
  @IBOutlet fileprivate weak var monthHeader: RxMonthHeaderView!
  @IBOutlet fileprivate weak var monthSectionView: RxMonthSectionView!
  @IBOutlet fileprivate weak var monthView: RxMonthView!
  fileprivate var disposable: DisposeBag!

  deinit {
    print("DEINIT \(self)")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    let decorator = AppDecorator()
    disposable = DisposeBag()

    let dependency = Singleton.instance
    let weekdayModel = RxCalendarLogic.SelectWeekday.Model(dependency)
    let weekdayVM = RxCalendarLogic.SelectWeekday.ViewModel(weekdayModel)
    let monthViewModel = RxCalendarLogic.MonthDisplay.Model(dependency)
    let monthViewVM = RxCalendarLogic.MonthDisplay.ViewModel(monthViewModel)
    let monthHeaderModel = RxCalendarLogic.MonthHeader.Model(dependency)
    let monthHeaderVM = RxCalendarLogic.MonthHeader.ViewModel(monthHeaderModel)
    let monthSectionModel = RxCalendarLogic.MonthSection.Model(dependency)
    let monthSectionVM = RxCalendarLogic.MonthSection.ViewModel(monthSectionModel)

    weekdayView.dependency = (weekdayVM, decorator)
    monthHeader.dependency = (monthHeaderVM, decorator)

    let pageCount = monthSectionVM.totalMonthCount
    let weekdayStacks = monthSectionVM.weekdayStacks
    let layout = RxMonthSectionHorizontalFlowLayout(pageCount, weekdayStacks)
    monthSectionView.setCollectionViewLayout(layout, animated: true)
    monthSectionView.dependency = (monthSectionVM, decorator)
    monthView.dependency = (monthViewVM, decorator)
  }
}
