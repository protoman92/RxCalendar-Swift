//
//  MonthAwareModel.swift
//  RxCalendarLogic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol RxMonthAwareModelFunction {

  /// Stream the current selected components.
  var currentMonthStream: Observable<RxCalendarLogic.Month> { get }
}
