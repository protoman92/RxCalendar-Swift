//
//  HorizontalSelectionHighlighter.swift
//  RxCalendar
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Horizontal selection highlighter.
public struct RxHorizontalSelectHighlighter {
  fileprivate var cornerRadius: CGFloat
  fileprivate var horizontalInset: CGFloat
  fileprivate var verticalInset: CGFloat
  fileprivate var highlightFillColor: UIColor

  /// Corner radii for bezier path.
  fileprivate var cornerRadii: CGSize {
    return CGSize(width: cornerRadius, height: cornerRadius)
  }

  public init() {
    cornerRadius = 5
    horizontalInset = 5
    verticalInset = 5
    highlightFillColor = .groupTableViewBackground
  }

  /// Copy all properties, but change the cornerRadius.
  public func with(cornerRadius: CGFloat) -> RxHorizontalSelectHighlighter {
    var highlighter = self
    highlighter.cornerRadius = cornerRadius
    return highlighter
  }

  /// Copy all properties, but change the horizontalInset.
  public func with(horizontalInset: CGFloat) -> RxHorizontalSelectHighlighter {
    var highlighter = self
    highlighter.horizontalInset = horizontalInset
    return highlighter
  }

  /// Copy all properties, but change the verticalInset.
  public func with(verticalInset: CGFloat) -> RxHorizontalSelectHighlighter {
    var highlighter = self
    highlighter.verticalInset = verticalInset
    return highlighter
  }

  /// Copy all properties, but change the highlight fill color.
  public func with(highlightFillColor: UIColor) -> RxHorizontalSelectHighlighter {
    var highlighter = self
    highlighter.highlightFillColor = highlightFillColor
    return highlighter
  }
}

// MARK: - RxSelectionHighlighterType
extension RxHorizontalSelectHighlighter: RxSelectionHighlighterType {
  public func drawHighlight(_ context: CGContext,
                            _ rect: CGRect,
                            _ part: RxCalendarLogic.HighlightPart) {
    context.saveGState()
    defer { context.restoreGState() }
    var highlightRect = rect.insetBy(dx: 0, dy: verticalInset)
    let bezier: UIBezierPath

    switch part {
    case .startAndEnd:
      highlightRect = highlightRect.insetBy(dx: horizontalInset, dy: 0)

      bezier = UIBezierPath(roundedRect: highlightRect,
                            cornerRadius: cornerRadius)

    case .start:
      highlightRect = highlightRect.offsetBy(dx: horizontalInset, dy: 0)

      bezier = UIBezierPath(roundedRect: highlightRect,
                            byRoundingCorners: [.topLeft, .bottomLeft],
                            cornerRadii: cornerRadii)

    case .end:
      highlightRect = CGRect(x: highlightRect.origin.x,
                             y: highlightRect.origin.y,
                             width: highlightRect.width - horizontalInset,
                             height: highlightRect.height)

      bezier = UIBezierPath(roundedRect: highlightRect,
                            byRoundingCorners: [.topRight, .bottomRight],
                            cornerRadii: cornerRadii)

    case .mid:
      bezier = UIBezierPath(rect: highlightRect)

    default:
      return
    }

    context.setFillColor(highlightFillColor.cgColor)
    bezier.fill()
  }
}
