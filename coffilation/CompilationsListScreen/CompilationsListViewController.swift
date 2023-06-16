//
//  CompilationsListViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 12.06.2023.
//

import Foundation
import UIKit

protocol CompilationsListViewProtocol: AnyObject {
	func didReceivedCompilations(isLoadAll: Bool, compilations: [Compilation])
	func appendCompilations(isLoadAll: Bool, with compilations: [Compilation])
	func didReceivedError()
}

class CompilationsListViewController: UIViewController {

	enum Style {
		case select
		case regular
	}

	private enum CollectionState {
		case loading
		case error
		case content
	}

	private let presenter: CompilationsListPresenterProtocol
	private let openCompilationScreen: (Compilation) -> Void
	private var compilations = [Compilation]()
	private var isLoadingMore = false
	private var isLoadAll = false

	private let compilationsListView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 32, height: 82)
		layout.scrollDirection = .vertical
		layout.minimumInteritemSpacing = 8
		layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 50)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.alwaysBounceVertical = true
		collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		collectionView.register(
			CompilationsListCollectionCell.self,
			forCellWithReuseIdentifier: CompilationsListCollectionCell.reuseIdentifier
		)
		collectionView.register(
			LoadingReusableView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
			withReuseIdentifier: LoadingReusableView.reuseIdentifier
		)
		collectionView.backgroundColor = .coffiLightGray
		return collectionView
	}()

	private let errorView = ErrorView(errorLabelText: "Не удалось загрузить коллекции :(", errorButtonText: "Попробовать снова")

	private let loadingStack: UIStackView = {
		let stack = UIStackView()
		stack.spacing = 8
		stack.axis = .vertical
		for _ in 0...4 {
			let loadingView = BigCompilationLoadingView()
			stack.addArrangedSubview(loadingView)
		}
		stack.distribution = .fillEqually
		return stack
	}()

	private let refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .clear
		return refresh
	}()

	private var loadingMoreView: LoadingReusableView?

	init(presenter: CompilationsListPresenterProtocol,
		 style: Style,
		 compilations: [Compilation] = [],
		 openCompilationScreen: @escaping  (Compilation) -> Void
	) {
		self.presenter = presenter
		self.compilations = compilations
		self.openCompilationScreen = openCompilationScreen
		super.init(nibName: nil, bundle: nil)
		compilationsListView.delegate = self
		compilationsListView.dataSource = self
		refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
		compilationsListView.refreshControl = refreshControl
		errorView.retryAction = { [weak self] in
			self?.updateCollectionState(with: .loading)
			self?.presenter.loadCompilations()
		}
		switch style {
		case .regular:
			setupNavigationBarForRegularList()
		case .select:
			setupNavigationBarForSelectList()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupLayout()
		updateCollectionState(with: .loading)
		presenter.loadCompilations()
		view.backgroundColor = .coffiLightGray
	}

	private func setupLayout() {
		view.addSubview(errorView)
		errorView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		errorView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
		errorView.autoAlignAxis(toSuperviewAxis: .horizontal)

		view.addSubview(loadingStack)
		loadingStack.autoPinEdgesToSuperviewSafeArea(with: .init(top: 16, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)

		view.addSubview(compilationsListView)
		compilationsListView.autoPinEdgesToSuperviewEdges()
	}

	private func updateCollectionState(with state: CollectionState) {
		refreshControl.endRefreshing()
		UIView.animateKeyframes(withDuration: 0.5, delay: 0) {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
				self.errorView.layer.opacity = 0
				self.loadingStack.layer.opacity = 0
				self.compilationsListView.alpha = 0
			}
			UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
				switch state {
				case .loading:
					self.loadingStack.layer.opacity = 1
				case .error:
					self.errorView.layer.opacity = 1
				case .content:
					self.compilationsListView.layer.opacity = 1
					self.compilationsListView.reloadData()
				}
			}
		}
	}

	private func setupNavigationBarForSelectList() {

	}

	private func setupNavigationBarForRegularList() {
		title = "Мои коллекции"
	}

	@objc private func didPullToRefresh() {
		updateCollectionState(with: .loading)
		presenter.loadCompilations()
	}
}

extension CompilationsListViewController: CompilationsListViewProtocol {
	func didReceivedCompilations(isLoadAll: Bool, compilations: [Compilation]) {
		self.isLoadAll = isLoadAll
		if isLoadAll {
			if let layout = compilationsListView.collectionViewLayout as? UICollectionViewFlowLayout {
				layout.footerReferenceSize = .zero
			}
		}
		self.compilations = compilations
		updateCollectionState(with: .content)
	}

	func appendCompilations(isLoadAll: Bool, with compilations: [Compilation]) {
		self.isLoadAll = isLoadAll
		if isLoadAll {
			if let layout = compilationsListView.collectionViewLayout as? UICollectionViewFlowLayout {
				layout.footerReferenceSize = .zero
			}
		}
		if !compilations.isEmpty {
			self.compilations.append(contentsOf: compilations)
			compilationsListView.reloadData()
		}
		isLoadingMore = false
	}

	func didReceivedError() {
		updateCollectionState(with: .error)
		isLoadAll = true
		isLoadingMore = false
	}
}

extension CompilationsListViewController: UICollectionViewDelegate {

}

extension CompilationsListViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		compilations.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.row == compilations.count - 1, !isLoadingMore, !isLoadAll {
			isLoadingMore = true
			presenter.loadMore()
		}

		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: CompilationsListCollectionCell.reuseIdentifier,
			for: indexPath
		) as? CompilationsListCollectionCell else {
			return UICollectionViewCell()
		}
		let compilation = compilations[indexPath.row]
		cell.configure(
			name: compilation.name,
			description: compilation.description,
			gradient: [compilation.gradient.startColor, compilation.gradient.endColor])

		return cell
	}

	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {
		guard let footerView = collectionView.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: LoadingReusableView.reuseIdentifier,
			for: indexPath
		) as? LoadingReusableView else {
			return UICollectionReusableView()
		}
		loadingMoreView = footerView
		return footerView
	}

	func collectionView(
		_ collectionView: UICollectionView,
		willDisplaySupplementaryView view: UICollectionReusableView,
		forElementKind elementKind: String,
		at indexPath: IndexPath
	) {
		if elementKind == UICollectionView.elementKindSectionFooter {
			loadingMoreView?.startAnimating()
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		didEndDisplayingSupplementaryView view: UICollectionReusableView,
		forElementOfKind elementKind: String,
		at indexPath: IndexPath
	) {
		if elementKind == UICollectionView.elementKindSectionFooter {
			loadingMoreView?.stopAnimating()
		}
	}
}
