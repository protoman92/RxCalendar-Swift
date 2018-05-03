//
//  Cell.swift
//  RxCalendar
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Date cell implementation for calendar view. This is the default cell that
/// will be used if no custom cells are specified.
public final class RxDateCell: UICollectionViewCell {
  @IBOutlet fileprivate weak var dateLbl: UILabel!

  private var circleMarkerId: String {
    return "DateCellCircleMarker"
  }

  /// Set this variable instead of setting each individually to ensure all draw
  /// dependencies are available at the same time.
  private var drawDependency: (RxCalendarLogic.Day, RxSelectionHighlighterType?)? {
    didSet { setNeedsDisplay() }
  }

  /// Store some properties here to perform some custom drawing.
  private var currentDay: RxCalendarLogic.Day? {
    return drawDependency?.0
  }

  private var selectionHighlighter: RxSelectionHighlighterType? {
    return drawDependency?.1
  }

  override public func draw(_ rect: CGRect) {
    defer { super.draw(rect) }

    guard
      let context = UIGraphicsGetCurrentContext(),
      let day = self.currentDay,
      let selectionHighlighter = self.selectionHighlighter else
    {
      return
    }

    // View hack here to remove weird border as a result of overriding drawRect.
    // This happens before the selection highlighter performs its custom draw
    // because we want it to override the strokes below if necessary.
    context.saveGState()

    if let backgroundColor = self.backgroundColor {
      context.setStrokeColor(backgroundColor.cgColor)
      context.stroke(rect)
    }

    context.restoreGState()
    selectionHighlighter.drawHighlight(context, rect, day.highlightPart)
  }

  /// Set up the current cell with a Day.
  ///
  /// - Parameter day: A Day instance.
  public func setupWithDay(_ decorator: RxDateCellDecoratorType,
                           _ day: RxCalendarLogic.Day) {
    self.drawDependency = (day, decorator.selectionHighlighter)
    guard let dateLbl = self.dateLbl else { return }

    if day.isCurrentMonth {
      backgroundColor = decorator.dateCellBackground(.normal)
      dateLbl.textColor = decorator.dateCellDescTextColor(.normal)
      dateLbl.font = decorator.dateCellDescFont(.normal)
    } else {
      backgroundColor = decorator.dateCellBackground(.isNotCurrentMonth)
      dateLbl.textColor = decorator.dateCellDescTextColor(.isNotCurrentMonth)
      dateLbl.font = decorator.dateCellDescFont(.isNotCurrentMonth)
    }

    if day.isSelected {
      backgroundColor = decorator.dateCellBackground(.isSelected)
    }

    dateLbl.text = day.dateDescription

    contentView.subviews
      .filter({$0.accessibilityIdentifier == circleMarkerId})
      .forEach({$0.removeFromSuperview()})

    if day.isSelected {
      dateLbl.textColor = decorator.dateCellDescTextColor(.isSelected)
      dateLbl.font = decorator.dateCellDescFont(.isSelected)
    }

    // If the day is today, add a circle marker programmatically.
    if day.isToday {
      let circleWidth = bounds.size.width * 2 / 3
      let circleSize = CGSize(width: circleWidth, height: circleWidth)
      let circleFrame = CGRect(origin: CGPoint.zero, size: circleSize)
      let circleMarker = UIView(frame: circleFrame)
      circleMarker.backgroundColor = decorator.dateCellTodayMarkerBackground
      circleMarker.center = CGPoint(x: bounds.midX, y: bounds.midY)
      circleMarker.layer.cornerRadius = circleWidth / 2
      circleMarker.accessibilityIdentifier = circleMarkerId
      contentView.insertSubview(circleMarker, at: 0)
      dateLbl.textColor = decorator.dateCellDescTextColor(.isToday)
      dateLbl.font = decorator.dateCellDescFont(.isToday)
    }
  }
}
