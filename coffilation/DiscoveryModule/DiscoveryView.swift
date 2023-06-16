//
//  DiscoveryView.swift
//  coffilation
//
//  Created by Матвей Борисов on 18.05.2023.
//

import UIKit
import PureLayout

protocol DiscoveryViewProtocol: UIView {
	func loadDiscovery(userId: Int)
	func didReceivedDiscovery(isEnd: Bool, compilations: [Compilation])
	func appendDiscovery(isEnd: Bool, with compilations: [Compilation])
	func didReceivedError()
}

class DiscoveryView: UIView {

	private enum CollectionState {
		case loading
		case error
		case content
	}

	private var presenter: DiscoveryPresenterProtocol

	private var discoveryCollections = [Compilation]()

	private let contentContainer = UIView()

	private let discoveryLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.text = "Находки"
		label.textAlignment = .left
		return label
	}()

	private let errorView = ErrorView(errorLabelText: "Не удалось загрузить находки :(", errorButtonText: "Попробовать снова")

	private let loadingView = DiscoveryLoadingView()

	private let discoveryCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 80, height: 100)
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .clear
		collectionView.alwaysBounceHorizontal = true
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.register(DiscoveryCollectionViewCell.self, forCellWithReuseIdentifier: DiscoveryCollectionViewCell.reuseIdentifier)
		return collectionView
	}()

	private lazy var paginationManager: HorizontalPaginationManager = {
		let manager = HorizontalPaginationManager(scrollView: discoveryCollectionView)
		return manager
	}()

	private var paginationCompletion: (() -> Void)?

	init(presenter: DiscoveryPresenterProtocol) {
		self.presenter = presenter
		super.init(frame: .zero)
		discoveryCollectionView.delegate = self
		discoveryCollectionView.dataSource = self
		paginationManager.delegate = self
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func updateCollectionState(with state: CollectionState) {
		UIView.animateKeyframes(withDuration: 0.5, delay: 0) {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
				self.errorView.layer.opacity = 0
				self.loadingView.layer.opacity = 0
				self.discoveryCollectionView.alpha = 0
			}
			UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
				switch state {
				case .loading:
					self.loadingView.layer.opacity = 1
				case .error:
					self.errorView.layer.opacity = 1
				case .content:
					self.discoveryCollectionView.layer.opacity = 1
					self.discoveryCollectionView.reloadData()
				}
			}
		}
	}

	private func setupLayout() {
		addSubview(discoveryLabel)
		discoveryLabel.autoPinEdgesToSuperviewEdges(
			with: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16),
			excludingEdge: .bottom
		)
		addSubview(contentContainer)
		contentContainer.autoPinEdge(.top, to: .bottom, of: discoveryLabel, withOffset: 12)
		contentContainer.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
		contentContainer.autoSetDimension(.height, toSize: 100)

		contentContainer.addSubview(errorView)
		errorView.autoPinEdgesToSuperviewEdges()

		contentContainer.addSubview(loadingView)
		loadingView.autoPinEdgesToSuperviewEdges()

		contentContainer.addSubview(discoveryCollectionView)
		discoveryCollectionView.autoPinEdgesToSuperviewEdges()
	}
}

extension DiscoveryView: DiscoveryViewProtocol {
	func loadDiscovery(userId: Int) {
		presenter.requestDiscovery(userId: userId)
		updateCollectionState(with: .loading)
		errorView.retryAction = { [weak self] in
			self?.updateCollectionState(with: .loading)
			self?.presenter.requestDiscovery(userId: userId)
		}
	}

	func didReceivedDiscovery(isEnd: Bool, compilations: [Compilation]) {
		paginationManager.isEnd = isEnd
		discoveryCollections = compilations
		updateCollectionState(with: .content)
		paginationCompletion?()
		paginationCompletion = nil
	}

	func didReceivedError() {
		updateCollectionState(with: .error)
		paginationCompletion?()
		paginationCompletion = nil
	}

	func appendDiscovery(isEnd: Bool, with compilations: [Compilation]) {
		paginationManager.isEnd = isEnd
		if !compilations.isEmpty {
			discoveryCollections.append(contentsOf: compilations)
			discoveryCollectionView.reloadData()
		}
		paginationCompletion?()
		paginationCompletion = nil
	}
}

extension DiscoveryView: UICollectionViewDelegate {

}

extension DiscoveryView: UICollectionViewDataSource {
	func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		discoveryCollections.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: DiscoveryCollectionViewCell.reuseIdentifier,
			for: indexPath
		) as? DiscoveryCollectionViewCell else {
			return UICollectionViewCell()
		}
		if discoveryCollections.count > 0 {
			let collection = discoveryCollections[indexPath.row]
			let gradient = [collection.gradient.startColor, collection.gradient.endColor]
			cell.configure(text: collection.name, gradient: gradient)
		} else {
			cell.configure(text: nil, gradient: [])
		}

		return cell
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumInteritemSpacingForSectionAt section: Int
	) -> CGFloat {
		return 8
	}
}

extension DiscoveryView: HorizontalPaginationManagerDelegate {
	func refreshAll(completion: @escaping () -> Void) {
		updateCollectionState(with: .loading)
		paginationCompletion = completion
		presenter.refreshAll()
	}

	func loadMore(completion: @escaping () -> Void) {
		paginationCompletion = completion
		presenter.loadMore()
	}
}
