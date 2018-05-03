//
//  MonthSectionLayout.swift
//  RxCalendar
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
import UIKit

/// Horizontal layout subclass for month section view.
///
/// How do we even test this?
public final class RxMonthSectionHorizontalFlowLayout: UICollectionViewFlowLayout {
  override public var collectionViewContentSize: CGSize {
    return collectionView
      .map({(width: $0.bounds.width, height: $0.bounds.height)})
      .map({(width: $0.width * CGFloat(pageCount), height: $0.height)})
      .map({CGSize(width: $0.width, height: $0.height)})
      .getOrElse(CGSize.zero)
  }

  fileprivate var contentWidth: CGFloat {
    return collectionView.map({$0.bounds.width * CGFloat(pageCount)}).getOrElse(0)
  }

  fileprivate var contentHeight: CGFloat {
    return collectionView.map({$0.bounds.height}).getOrElse(0)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let pageCount: Int
  private let weekdayStacks: Int
  private var cache: [Int : [UICollectionViewLayoutAttributes]]

  public init(_ pageCount: Int, _ weekdayStacks: Int) {
    self.pageCount = pageCount
    self.weekdayStacks = weekdayStacks
    cache = [:]
    super.init()
    minimumLineSpacing = 0
    minimumInteritemSpacing = 0
    sectionInset = .zero
  }

  override public func prepare() {
    super.prepare()

    guard
      let collectionView = self.collectionView,
      collectionView.numberOfSections > 0,
      cache.isEmpty else
    {
      return
    }

    let weekdays = RxCalendarLogic.Util.weekdayCount
    let parentWidth = collectionView.bounds.width
    let parentHeight = collectionView.bounds.height
    let cellWidth = parentWidth / CGFloat(RxCalendarLogic.Util.weekdayCount)
    let cellHeight = parentHeight / CGFloat(weekdayStacks)

    for page in 0..<pageCount {
      var pageAttrs = [UICollectionViewLayoutAttributes]()

      for row in 0..<weekdayStacks {
        for column in 0..<weekdays {
          let offset = CGFloat(page) * parentWidth
          let x = offset + CGFloat(column) * cellWidth
          let y = CGFloat(row) * cellHeight
          let index = IndexPath(row: row * weekdays + column, section: page)
          let attrs = UICollectionViewLayoutAttributes(forCellWith: index)
          attrs.frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
          pageAttrs.append(attrs)
        }
      }

      cache[page] = pageAttrs
    }
  }

  override public func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]?
  {
    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

    for (_, pageAttrs) in cache {
      for attr in pageAttrs {
        if attr.frame.intersects(rect) {
          visibleLayoutAttributes.append(attr)
        }
      }
    }
    return visibleLayoutAttributes
  }

  override public func layoutAttributesForItem(at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    if
      let pageRects = cache[indexPath.section],
      indexPath.row >= 0 && indexPath.row < pageRects.count
    {
      return pageRects[indexPath.row]
    } else {
      return super.layoutAttributesForItem(at: indexPath)
    }
  }
}
