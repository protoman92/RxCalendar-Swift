//
//  WeekdayView.swift
//  calendar99
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxCalendarLogic
import RxDataSources
import RxSwift

/// Weekday view that displays weekdays.
public final class RxWeekdayView: UICollectionView {
  public typealias Decorator = RxWeekdayViewDecoratorType
  public typealias ViewModel = RxWeekdayDisplayViewModelType
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

// MARK: - UICollectionViewFlowLayout
extension RxWeekdayView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int)
    -> CGFloat
  {
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int)
    -> CGFloat
  {
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    let bounds = collectionView.bounds

    // If the width is larger then the height, this should be a horizontal
    // scrolling view & vice versa.
    if bounds.width > bounds.height {
      let width = bounds.width / CGFloat(RxCalendarLogic.Util.weekdayCount)
      return CGSize(width: width, height: bounds.height)
    } else {
      let height = bounds.height / CGFloat(RxCalendarLogic.Util.weekdayCount)
      return CGSize(width: bounds.width, height: height)
    }
  }
}

// MARK: - Views.
public extension RxWeekdayView {
  fileprivate var cellId: String {
    return "WeekdayCell"
  }

  fileprivate func setupViews() {
    let bundle = Bundle(for: RxWeekdayView.classForCoder())
    let cellNib = UINib(nibName: "WeekdayCell", bundle: bundle)
    register(cellNib, forCellWithReuseIdentifier: cellId)
  }

  fileprivate func setupViewsWithDecorator() {
    guard let decorator = self.decorator else { return }
    backgroundColor = decorator.weekdayViewBackground
  }
}

// MARK: - Data sources.
public extension RxWeekdayView {
  typealias Section = SectionModel<String, RxCalendarLogic.Weekday>
  typealias CVSource = CollectionViewSectionedDataSource<Section>
  typealias RxDataSource = RxCollectionViewSectionedReloadDataSource<Section>

  fileprivate func setupDataSource() -> RxDataSource {
    let dataSource = RxDataSource(configureCell: {[weak self] in
      return self?.configureCell($0, $1, $2, $3) ?? UICollectionViewCell()
    })

    dataSource.canMoveItemAtIndexPath = {(_, _) in false}
    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item) -> UICollectionViewCell {
    guard
      let decorator = self.decorator?.weekdayCellDecorator(indexPath, item),
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: cellId,
        for: indexPath) as? RxWeekdayCell else
    {
      #if DEBUG
      fatalError("Invalid properties")
      #else
      return UICollectionViewCell()
      #endif
    }

    cell.setupWithWeekday(decorator, item)
    return cell
  }
}

// MARK: - View model bindings.
public extension RxWeekdayView {
  fileprivate func bindViewModel() {
    guard let viewModel = self.viewModel else {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    viewModel.setupWeekDisplayBindings()
    let disposable = self.disposable
    let dataSource = setupDataSource()
    self.rx.setDelegate(self).disposed(by: disposable)

    viewModel.weekdayStream
      .map({[Section(model: "", items: $0)]})
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)

    self.rx.itemSelected.map({$0.row})
      .bind(to: viewModel.weekdaySelectionIndexReceiver)
      .disposed(by: disposable)
  }
}
