//
//  Decorator.swift
//  RxCalendarDemo
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendar
import RxCalendarLogic
import RxCalendarPreset

public struct AppDecorator {
  fileprivate let dateCellHighlighter: RxSelectionHighlighterType

  public init() {
    dateCellHighlighter = RxHorizontalSelectHighlighter()
      .with(cornerRadius: 10)
      .with(horizontalInset: 5)
      .with(verticalInset: 5)
      .with(highlightFillColor: UIColor(
        red: 237 / 255,
        green: 246 / 255,
        blue: 251 / 255,
        alpha: 1))
  }
}

extension AppDecorator: RxMonthHeaderDecoratorType {
  public var navigationButtonTintColor: UIColor {
    return .black
  }

  public var navigationButtonDisabledTintColor: UIColor {
    return .lightGray
  }

  public var monthDescriptionTextColor: UIColor {
    return .black
  }

  public var monthDescriptionFont: UIFont {
    return UIFont.systemFont(ofSize: 17)
  }
}

extension AppDecorator: RxWeekdayViewDecoratorType {
  public var weekdayViewBackground: UIColor {
    return .white
  }

  public func weekdayCellDecorator(_ indexPath: IndexPath,
                                   _ item: RxCalendarLogic.Weekday)
    -> RxWeekdayCellDecoratorType
  {
    return self
  }
}

extension AppDecorator: RxWeekdayCellDecoratorType {
  public var weekdayDescriptionTextColor: UIColor {
    return UIColor.black
  }

  public var weekdayDescriptionFont: UIFont {
    return UIFont.systemFont(ofSize: 16)
  }
}

extension AppDecorator: RxDateCellDecoratorType {
  public var selectionHighlighter: RxSelectionHighlighterType? {
    return dateCellHighlighter
  }

  public var dateCellTodayMarkerBackground: UIColor {
    return UIColor(red: 56 / 255, green: 147 / 255, blue: 217 / 255, alpha: 1)
  }

  public func dateCellDescTextColor(_ state: RxDateCellDescState) -> UIColor {
    switch state {
    case .normal: return .black
    case .isNotCurrentMonth: return .white

    case .isSelected: return UIColor(
      red: 56 / 255,
      green: 147 / 255,
      blue: 217 / 255,
      alpha: 1)

    case .isToday: return .white
    }
  }

  public func dateCellDescFont(_ state: RxDateCellDescState) -> UIFont {
    switch state {
    case .isSelected, .isToday: return UIFont.boldSystemFont(ofSize: 16)
    default: return UIFont.systemFont(ofSize: 16)
    }
  }

  public func dateCellBackground(_ state: RxDateCellBackgroundState) -> UIColor {
    switch state {
    case .normal: return .white
    case .isSelected: return .white
    case .isNotCurrentMonth: return .lightGray
    }
  }
}

extension AppDecorator: RxMonthViewDecoratorType {
  public var monthViewBackgroundColor: UIColor {
    return .white
  }
}

extension AppDecorator: RxMonthSectionDecoratorType {
  public var monthSectionBackgroundColor: UIColor {
    return .white
  }

  public var monthSectionPagingEnabled: Bool {
    return true
  }

  public func dateCellDecorator(_ indexPath: IndexPath, _ item: RxCalendarLogic.Day)
    -> RxDateCellDecoratorType
  {
    return self
  }
}

extension AppDecorator: RxRegularCalendarDecoratorType {}
