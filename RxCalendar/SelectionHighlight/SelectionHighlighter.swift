//
//  Highlighter.swift
//  RxCalendar
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Date selection highlighter that draws highlights on a Rect.
public protocol RxSelectionHighlighterType {

  /// Draw highlights in a rect with the specified highlight part.
  ///
  /// - Parameters:
  ///   - context: A CGContext instance.
  ///   - rect: A CGRect instance.
  ///   - part: A HighlightPart instance.
  func drawHighlight(_ context: CGContext,
                     _ rect: CGRect,
                     _ part: RxCalendarLogic.HighlightPart)
}
