//
//  HorizontalPaginationManager.swift
//  coffilation
//
//  Created by Матвей Борисов on 11.06.2023.
//

import Foundation
import UIKit

protocol HorizontalPaginationManagerDelegate: AnyObject {
	func refreshAll(completion: @escaping () -> Void)
	func loadMore(completion: @escaping () -> Void)
}

class HorizontalPaginationManager {

	private var isLoading = false
	private var scrollView: UICollectionView!
	private var rightMostLoader: UIView?
	var refreshViewColor: UIColor = .white
	var isEnd = false
	private var scrollViewObservation: NSKeyValueObservation?

	weak var delegate: HorizontalPaginationManagerDelegate?

	init(scrollView: UICollectionView) {
		self.scrollView = scrollView
		self.addScrollViewOffsetObserver()
	}

	func initialLoad() {
		self.delegate?.refreshAll(completion: {})
	}

	private var oldInset: CGFloat = 0
	private var oldContentOffset: CGPoint = .zero

	private func addRightMostControl() {
		let view = UIView()
		view.backgroundColor = .coffiLightGray
		view.frame.origin = CGPoint(x: self.scrollView.contentSize.width,
									y: 0)
		view.frame.size = CGSize(width: 60,
								 height: self.scrollView.bounds.height)
		let activity = UIActivityIndicatorView(style: .large)
		activity.frame = view.bounds
		activity.startAnimating()
		view.addSubview(activity)
		oldInset = scrollView.contentInset.right
		self.scrollView.contentInset.right = view.frame.width
		self.rightMostLoader = view
		self.scrollView.addSubview(view)
		oldContentOffset = scrollView.contentOffset
	}

	func removeRightLoader() {
		rightMostLoader?.removeFromSuperview()
		rightMostLoader = nil
		scrollView.contentInset.right = oldInset
		scrollView.setContentOffset(oldContentOffset, animated: false)
	}

}

// MARK: OFFSET OBSERVER
extension HorizontalPaginationManager {

	private func addScrollViewOffsetObserver() {
		scrollViewObservation = self.scrollView.observe(\UICollectionView.contentOffset, options: .new) { [weak self] _, change in
			guard let newValue = change.newValue else {
				return
			}
			self?.setContentOffSet(newValue)
		}
	}

	private func setContentOffSet(_ offset: CGPoint) {
		let offsetX = offset.x
		if offsetX < -120 && !self.isLoading {
			self.isLoading = true
			self.delegate?.refreshAll {
				self.isLoading = false
			}
			return
		}

		let contentWidth = scrollView.collectionViewLayout.collectionViewContentSize.width
		let frameWidth = scrollView.bounds.size.width
		let diffX = contentWidth - frameWidth
		if contentWidth > frameWidth,
		   offsetX > (diffX + 80),
		   !isLoading,
		   !isEnd {
			isLoading = true
			addRightMostControl()
			delegate?.loadMore {
				self.removeRightLoader()
				self.isLoading = false
			}
		}
	}

}
