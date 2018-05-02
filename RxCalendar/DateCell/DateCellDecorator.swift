//
//  DateCellDecorator.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Decorator for date cell.
public protocol RxDateCellDecoratorType {

  /// Selection highlighter. If this is nil, skip selection highlighting.
  var selectionHighlighter: RxSelectionHighlighterType? { get }

  /// Background color for today marker.
  var dateCellTodayMarkerBackground: UIColor { get }

  /// Text color for date description label.
  ///
  /// - Parameter state: A RxDateCellDescState instance.
  /// - Returns: An UIColor value.
  func dateCellDescTextColor(_ state: RxDateCellDescState) -> UIColor

  /// Font for date description label.
  ///
  /// - Parameter state: A RxDateCellDescState instance.
  /// - Returns: An UIFont instance.
  func dateCellDescFont(_ state: RxDateCellDescState) -> UIFont

  /// Background color for background.
  ///
  /// - Parameter state: A RxDateCellBackgroundState instance.
  /// - Returns: A UIColor value.
  func dateCellBackground(_ state: RxDateCellBackgroundState) -> UIColor
}
