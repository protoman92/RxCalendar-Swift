//
//  RegularCalendarDecorator.swift
//  RxCalendarPreset
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Decorator for RegularCalendar.
public protocol RxRegularCalendarDecoratorType:
  RxMonthHeaderDecoratorType,
  RxMonthSectionDecoratorType,
  RxWeekdayViewDecoratorType {}
