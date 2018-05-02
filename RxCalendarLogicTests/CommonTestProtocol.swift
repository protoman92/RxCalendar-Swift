//
//  CommonTestProtocol.swift
//  RxCalendarLogicTests
//
//  Created by Hai Pham on 21/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest

/// Common tests.
public protocol CommonTestProtocol {
  var disposable: DisposeBag! { get set }
  var firstWeekdayForTest: Int! { get set }
  var iterations: Int! { get set }
  var scheduler: TestScheduler! { get set }
  var waitDuration: TimeInterval! { get set }
}
