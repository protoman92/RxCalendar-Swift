//
//  MonthSectionView.swift
//  RxCalendar
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxDataSources
import RxSwift
import UIKit

/// Divide months into sections. This view should provide swiping animations
/// when switching from one month to another, but the caveat is that there are
/// a finite number of months. However, if we set that number high enough, I
/// doubt the user would be able to scroll past the limits anyway.
public final class RxMonthSectionView: UICollectionView {
  public typealias Decorator = RxMonthSectionDecoratorType
  public typealias ViewModel = RxMonthSectionViewModelType
  public typealias Dependency = (ViewModel, Decorator)

  public var dependency: Dependency? {
    willSet {
      #if DEBUG
      if dependency != nil {
        fatalError("Cannot mutate!")
      }
      #endif
    }
    
    didSet {
      bindViewModel()
      setupViewsWithDecorator()
    }
  }

  fileprivate var viewModel: ViewModel? { return dependency?.0 }
  fileprivate var decorator: Decorator? { return dependency?.1 }
  fileprivate lazy var disposable: DisposeBag = DisposeBag()

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }

  override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    setupViews()
  }
}

// MARK: - Views.
public extension RxMonthSectionView {
  fileprivate var cellId: String {
    return "DateCell"
  }

  fileprivate func setupViews() {
    let bundle = Bundle(for: RxDateCell.classForCoder())
    let cellNib = UINib(nibName: "DateCell", bundle: bundle)
    register(cellNib, forCellWithReuseIdentifier: cellId)
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    isPagingEnabled = true
  }

  fileprivate func setupViewsWithDecorator() {
    guard let decorator = self.decorator else { return }
    backgroundColor = decorator.monthSectionBackgroundColor
  }
}

// MARK: - Data source.
public extension RxMonthSectionView {
  typealias Section = RxCalendarLogic.MonthComp
  typealias CVSource = CollectionViewSectionedDataSource<Section>
  typealias RxDataSource = RxCollectionViewSectionedAnimatedDataSource<Section>

  /// Use RxDataSource to drive data.
  fileprivate func setupDataSource() -> RxDataSource {
    let dataSource = RxDataSource(
      configureCell: {[weak self] in
        if let `self` = self {
          return self.configureCell($0, $1, $2, $3)
        } else {
          return UICollectionViewCell()
        }
      },
      configureSupplementaryView: {(_, _, _, _) in UICollectionReusableView()}
    )

    dataSource.canMoveItemAtIndexPath = {(_, _) in false}
    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item)
    -> UICollectionViewCell
  {
    let sections = source.sectionModels
    let section = indexPath.section

    guard
      section >= 0 && section < source.sectionModels.count,
      let viewModel = self.viewModel,
      let decorator = self.decorator,
      let day = viewModel.dayFromFirstDate(sections[section].month, item),
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: cellId,
        for: indexPath) as? RxDateCell else
    {
      #if DEBUG
      fatalError("Invalid properties")
      #else
      return UICollectionViewCell()
      #endif
    }

    let actualDay = day
      .with(selected: viewModel.isDateSelected(day.date))
      .with(highlightPart: viewModel.highlightPart(day.date))

    let cellDecorator = decorator.dateCellDecorator(indexPath, actualDay)
    cell.setupWithDay(cellDecorator, actualDay)
    return cell
  }
}

// MARK: - View model bindings.
public extension RxMonthSectionView {

  /// Bind month section view model.
  fileprivate func bindViewModel() {
    guard let viewModel = self.viewModel else {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    viewModel.setupAllBindingsAndSubBindings()
    let disposable = self.disposable
    let dataSource = setupDataSource()

    viewModel.monthCompStream
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)

    let selectionStream = viewModel.currentMonthSelectionIndexStream.share(replay: 1)

    // The scroll position actually affects the cell layout, so be sure to
    // choose carefully.
    selectionStream
      .observeOn(MainScheduler.instance)
      .bind(onNext: {[weak self] in
        self?.scrollToItem(at: IndexPath(row: 0, section: $0),
                           at: .left,
                           animated: true)
      })
      .disposed(by: disposable)

    // Detect swipes to change current selection.
    let movementStream = self.rx.didEndDecelerating
      .withLatestFrom(selectionStream)
      .map({[weak self] in (self?.calculateOffsetChange($0)) ?? 0})
      .share(replay: 1)

    movementStream
      .filter({$0 >= 0}).map({_ in})
      .bind(to: viewModel.currentMonthForwardReceiver)
      .disposed(by: disposable)

    movementStream
      .filter({$0 < 0}).map({_ in})
      .bind(to: viewModel.currentMonthBackwardReceiver)
      .disposed(by: disposable)

    self.rx.itemSelected
      .map({RxCalendarLogic.GridPosition($0.section, $0.row)})
      .bind(to: viewModel.gridSelectionReceiver)
      .disposed(by: disposable)

    viewModel.gridSelectionChangesStream
      .map({$0.map({IndexPath(row: $0.dayIndex, section: $0.monthIndex)})})
      .observeOn(MainScheduler.instance)
      .bind(onNext: {[weak self] in self?.reloadItems(at: $0)})
      .disposed(by: disposable)
  }

  /// Calculate the change in offset relative to the previous selection index.
  private func calculateOffsetChange(_ pix: Int) -> Int {
    let offset = self.contentOffset
    let bounds = self.bounds

    // Since this view can either be horizontal or vertical, only one origin
    // coordinate (x or y) will be positive, so we need to check for both cases.
    // We also compare with the offset for the previous selection index.
    if offset.x == 0 && offset.y == 0 {
      return -pix
    } else if offset.x > 0 {
      return Int((offset.x - CGFloat(pix) * bounds.width) / bounds.width)
    } else {
      return Int((offset.y - CGFloat(pix) * bounds.height) / bounds.height)
    }
  }
}

// MARK: - IdentifiableType
extension RxCalendarLogic.MonthComp: IdentifiableType {
  public typealias Identity = String

  public var identity: String {
    return "\(month.month)-\(month.year)"
  }
}

/// Notice that we don't actually store any data here - this is done so that
/// the memory footprint is as small as possible. If a cell requires data to
/// display, that data will be calculated at the time it's requested.
extension RxCalendarLogic.MonthComp: AnimatableSectionModelType {
  public typealias Item = Int

  public var items: [Item] {
    return (0..<dayCount).map({$0})
  }

  public init(original: RxCalendarLogic.MonthComp, items: [Item]) {
    self.init(original.month, items.count, original.firstWeekday)
  }
}
