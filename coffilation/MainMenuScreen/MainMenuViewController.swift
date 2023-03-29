//
//  MainMenuViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit
import UBottomSheet

class MainMenuViewController: UIViewController {

	var sheetCoordinator: UBottomSheetCoordinator?

	var presenter: MainMenuPresenterProtocol?

	private var discoveryCollections = [Collection]()
	private var ownCollections = [Collection]()

	private let dragView: UIView = {
		let view = UIView()
		view.backgroundColor = .middleGray
		return view
	}()

	private let searchTextField: UITextField = {
		let field = UITextField()
		field.backgroundColor = .white
		let searchImageView = UIImageView(image: CoffilationImage.search)
		searchImageView.tintColor = .darkGray
		searchImageView.contentMode = .scaleAspectFit
		field.setLeftView(with: searchImageView, insets: UIEdgeInsets(top: 1, left: 4, bottom: 0, right: 4))
		field.attributedPlaceholder = NSAttributedString(
			string: "Поиск...",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
		return field
	}()

	private let avatarView: SkeletonView = {
		let view = SkeletonView()
		return view
	}()

	private let discoveryLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.text = "Находки"
		label.textAlignment = .left
		return label
	}()

	private let discoveryCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 80, height: 100)
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .clear
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.register(DiscoveryCollectionViewCell.self, forCellWithReuseIdentifier: DiscoveryCollectionViewCell.reuseIdentifier)
		return collectionView
	}()

	private let collectionsLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		label.text = "Мои коллекции"
		label.textAlignment = .left
		return label
	}()

	private let createButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Создать", for: .normal)
		button.setTitleColor(.mainColor, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		return button
	}()

	private let collectionsTableView: UITableView = {
		let table = UITableView()
		table.backgroundColor = .white
		table.separatorColor = .middleGray
		table.separatorStyle = .singleLine
		table.isScrollEnabled = false
		table.bounces = false
		table.register(CollectionTableViewCell.self, forCellReuseIdentifier: CollectionTableViewCell.reuseIdentifier)
		return table
	}()

	private var tableViewHeightConstraint: NSLayoutConstraint?

	private let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.showsVerticalScrollIndicator = false
		return scroll
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		collectionsTableView.delegate = self
		collectionsTableView.dataSource = self
		discoveryCollectionView.delegate = self
		discoveryCollectionView.dataSource = self
		setupLayout()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		dragView.roundCorners(corners: .allCorners, radius: 2.5, rect: dragView.bounds)
		avatarView.roundCorners(corners: .allCorners, radius: 18, rect: avatarView.bounds)
		searchTextField.roundCorners(corners: .allCorners, radius: 10, rect: searchTextField.bounds)
		collectionsTableView.roundCorners(corners: .allCorners, radius: 10, rect: collectionsTableView.bounds)
		sheetCoordinator?.startTracking(item: self)
		requestProfileInfo()
	}

	private func setupLayout() {
		view.backgroundColor = .coffiLightGray
		view.addSubview(scrollView)
		scrollView.autoPinEdgesToSuperviewEdges()
		let containerView = UIView()
		scrollView.addSubview(containerView)
		containerView.autoMatch(.width, to: .width, of: scrollView)
		containerView.autoPinEdgesToSuperviewEdges()

		containerView.addSubview(dragView)
		dragView.autoPinEdge(toSuperviewEdge: .top, withInset: 4)
		dragView.autoSetDimensions(to: CGSize(width: 36, height: 5))
		dragView.autoAlignAxis(toSuperviewAxis: .vertical)

		containerView.addSubview(searchTextField)
		searchTextField.autoPinEdge(.top, to: .bottom, of: dragView, withOffset: 7)
		searchTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
		searchTextField.autoSetDimension(.height, toSize: 36)

		containerView.addSubview(avatarView)
		avatarView.autoPinEdge(.top, to: .bottom, of: dragView, withOffset: 7)
		avatarView.autoSetDimensions(to: CGSize(width: 36, height: 36))
		avatarView.autoPinEdge(.left, to: .right, of: searchTextField, withOffset: 10)
		avatarView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)

		containerView.addSubview(discoveryLabel)
		discoveryLabel.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 16)
		discoveryLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
		discoveryLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)

		containerView.addSubview(discoveryCollectionView)
		discoveryCollectionView.autoPinEdge(toSuperviewEdge: .left)
		discoveryCollectionView.autoPinEdge(toSuperviewEdge: .right)
		discoveryCollectionView.autoPinEdge(.top, to: .bottom, of: discoveryLabel, withOffset: 12)
		discoveryCollectionView.autoSetDimension(.height, toSize: 110)

		containerView.addSubview(collectionsLabel)
		collectionsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
		collectionsLabel.autoPinEdge(.top, to: .bottom, of: discoveryCollectionView, withOffset: 14)
		collectionsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

		containerView.addSubview(createButton)
		createButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
		createButton.autoPinEdge(.top, to: .bottom, of: discoveryCollectionView, withOffset: 14)
		createButton.autoPinEdge(.left, to: .right, of: collectionsLabel)
		createButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		createButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		createButton.autoMatch(.height, to: .height, of: collectionsLabel)

		containerView.addSubview(collectionsTableView)
		collectionsTableView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
		collectionsTableView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
		collectionsTableView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20, relation: .greaterThanOrEqual)
		collectionsTableView.autoPinEdge(.top, to: .bottom, of: collectionsLabel, withOffset: 12)
		tableViewHeightConstraint = collectionsTableView.autoSetDimension(.height, toSize: 82)
	}

	private func requestProfileInfo() {
		avatarView.start()
		presenter?.requestUserInfo()
	}

	private func setupAvatarView(with userName: String?) {
		let name = userName ?? "?"
		let gradient = avatarView.addGradient(colors: UIColor.redGradient)
		gradient.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		label.text = name.prefix(1).capitalized
		label.textColor = .white
		avatarView.addSubview(label)
		label.autoCenterInSuperview()
	}

	private func setupActions() {
		createButton.addTarget(self, action: #selector(createNewCollection), for: .touchUpInside)
	}

	@objc private func createNewCollection() {

	}

	func draggableView() -> UIScrollView? {
		scrollView
	}
}

extension MainMenuViewController: MainMenuViewProtocol {
	func didReceivedUserInfo(with user: User?) {
		avatarView.stop()
		guard let user else {
			setupAvatarView(with: nil)
			return
		}
		setupAvatarView(with: user.name)
		presenter?.requestCollections(for: user.id)
		presenter?.requestDiscovery(for: user.id)
	}

	func didReceivedDiscovery(collections: [Collection]) {
		discoveryCollections = collections
		discoveryCollectionView.reloadData()
	}

	func didReceivedCollections(collections: [Collection]) {
		ownCollections = collections
		collectionsTableView.reloadData()
	}
}

extension MainMenuViewController: UICollectionViewDelegate {
}

extension MainMenuViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		discoveryCollections.count == 0 ? 3 : discoveryCollections.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoveryCollectionViewCell.reuseIdentifier,
															for: indexPath) as? DiscoveryCollectionViewCell
		else { return UICollectionViewCell() }
		if discoveryCollections.count > 0 {
			let collection = discoveryCollections[indexPath.row]
			var gradient = [CGColor]()
			if let firstColor = collection.gradient?.startColor, let secondColor = collection.gradient?.endColor {
				gradient = [firstColor, secondColor]
			}
			cell.configure(text: collection.name, gradient: gradient)

		} else {
			cell.configure(text: nil, gradient: [])
		}

		return cell
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 8
	}
}

extension MainMenuViewController: UITableViewDelegate {

}

extension MainMenuViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		let items = ownCollections.count == 0 ? ownCollections.count : ownCollections.count
		tableViewHeightConstraint?.constant = 82 * CGFloat(ownCollections.count)
		view.setNeedsUpdateConstraints()
		view.setNeedsLayout()
		return ownCollections.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.reuseIdentifier,
													   for: indexPath) as? CollectionTableViewCell else { return UITableViewCell() }
		if ownCollections.count > 0 {
			let collection = ownCollections[indexPath.row]
			var gradient = [CGColor]()
			if let firstColor = collection.gradient?.startColor, let secondColor = collection.gradient?.endColor {
				gradient = [firstColor, secondColor]
			}
			cell.configure(name: collection.name, description: collection.description, gradient: gradient)

		} else {
			cell.configure(name: nil, description: nil, gradient: [])
		}
		return cell
	}
}

extension MainMenuViewController: Draggable {}
