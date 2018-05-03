# RxCalendar

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/protoman92/RxCalendar-Swift.svg?branch=master)](https://travis-ci.org/protoman92/RxCalendar-Swift)
[![Coverage Status](https://coveralls.io/repos/github/protoman92/RxCalendar-Swift/badge.svg?branch=master&dummy=false)](https://coveralls.io/github/protoman92/RxCalendar-Swift?branch=master&dummy=false)

(This is a clone of another repository that I did but no longer have access to, so the commit count does not reflect actual effort).

Almost fully-configurable calendar view for iOS applications that runs entirely on Rx.

<img width="418" alt="screen shot 2018-04-24 at 3 44 19 pm" src="https://user-images.githubusercontent.com/12141908/39176228-851bc97e-47d6-11e8-9ac0-6b65e8ca6d14.png">

Note that the top and bottom calendars are two different types of views that are driven by the same streams, so any selection or change in month from one view will also show up on the other.

Reactive programming allows us to produce truly decoupled components that are open to extensions but closed for modications. For example, date selections in a month view are driven by a selected date stream (**Observable[Set[Date]]**), so if we want to add a weekday bar view with logic such that clicking on a weekday (e.g. **Monday**) selects the entire date range (corresponding to said weekday), all we need to do is just push a custom set of selected dates into the stream and we will see those dates being selected automatically.

If ever so required, we can write bridges that connect imperative and reactive to cater to legacy code, but it's best to minimize such bridges if we want to build scalable applications.

The relevant components included in this repository are:

- **MonthView**: A simple calendar view that does date calculations lazily depending on the currently selected month. It's very lightweight, but lacks the flipping animations present in **MonthSectionView**. It's capable of: **MonthGrid**, **MonthControl**, **SingleDaySelection**.

- **MonthSectionView**: Traditional swipe calendar view that caches months as specified. Since this view needs to store months and cell attributes, it is a bit slower than **MonthView**. It's capable of: **MonthGrid**, **MonthControl**, **SingleDaySelection**.

- **MonthHeaderView**: Header view that displays the currently selected month and possesses buttons that allow month navigations. It's capable of: **MonthControl**.

- **WeekdayView**: Simple list-based view that displays weekdays. It's capable of: **WeedayDisplay**.

- **SelectableWeekdayView**: **WeekdayView** decorator that allows the user to select all dates with a particular weekday. It's capable of: **WeekdayDisplay**, **MultiDaySelection**. 

Each of these views requires its own **ViewModel** and **Model**, so we must be sure to inject those after creating them.

## Terminologies

- Any protocol that ends with **Function** means it contains functionalities which are shared between/among two or more classes/protocols. For example, **RxxxFunction** contains shared functionalities between a model and view model for a specific view; **RxxxModelFunction** is the same for a model and its dependency.

- Any protocol whose name contains **Default** or **NoDefault** has properties that are defaultable or non-defaultable.

- Usually protocols will have the postfix **Type**, (e.g. **ViewModelType**, **ModelType**), but not always. A **ViewModel** will have a protocol **ViewModelType** and an implementation.

- Actual model and view model implementations are nested in classes defined in **Entry.swift** (e.g. **RxCalendarLogic.MonthSection.ViewModel**).

## Presets

- The target **RxCalendarPreset** contains preset views with commonly used templates.

- More presets will be added if the need arises.

## Namespace

- **RxCalendarLogic** contains basic logic, **Model** and **ViewModel** for views in **RxCalendar** target. All classes under this namespace can be found in **RxCalendarLogic**, and the entry file for this namespace is **LogicEntry.swift**.

- **RxCalendarRedux** contains Redux components. All classes under this namespace can be found in **RxCalendarRedux**, and the entry file for this namespace is **ReduxEntry.swift**.

- **RxCalendarLegacy** contains legacy components. All classes under this namespace can be found in **RxCalendarLegacy**, and the entry file for this namespace is **LegacyEntry.swift**.

## Legacy bridge

- If you find the amount of dependencies to implement too daunting, and have reservations towards reactive programming, check out legacy bridges in **RxCalendarLegacy**.

## Installation

This library uses **Cocoapods** with multiple subspecs, which can be installed like so:

```ruby
pod 'RxCalendar', subspecs: [
  'Redux',
  'RegularCalendarLegacy',
]
```

Check out **RxCalendar.podspec** for a list of available subspecs.
