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

	private let presenter: MainMenuPresenterProtocol

	private var ownCollections = [Compilation]()

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

	private let discoveryView: DiscoveryViewProtocol
	private let myCompilationsView: MyCompilationsViewProtocol

	private var tableViewHeightConstraint: NSLayoutConstraint?

	private let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.showsVerticalScrollIndicator = false
		return scroll
	}()

	init(
		presenter: MainMenuPresenter,
		discoveryView: DiscoveryViewProtocol,
		myCompilationView: MyCompilationsViewProtocol
	) {
		self.presenter = presenter
		self.discoveryView = discoveryView
		self.myCompilationsView = myCompilationView
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupLayout()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		sheetCoordinator?.startTracking(item: self)
		requestProfileInfo()
		setupActions()
		navigationController?.setNavigationBarHidden(true, animated: true)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		dragView.roundCorners(corners: .allCorners, radius: 2.5, rect: dragView.bounds)
		avatarView.roundCorners(corners: .allCorners, radius: 18, rect: avatarView.bounds)
		searchTextField.roundCorners(corners: .allCorners, radius: 10, rect: searchTextField.bounds)
		navigationController?.navigationBar.topItem?.title = ""
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

		containerView.addSubview(discoveryView)
		discoveryView.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 16)
		discoveryView.autoPinEdge(toSuperviewEdge: .left)
		discoveryView.autoPinEdge(toSuperviewEdge: .right)

		containerView.addSubview(myCompilationsView)
		myCompilationsView.autoPinEdge(.top, to: .bottom, of: discoveryView)
		myCompilationsView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
	}

	private func requestProfileInfo() {
		avatarView.start()
		presenter.requestUserInfo()
	}

	private func setupAvatarView(with userName: String?) {
		let name = userName ?? "?"
		let gradient = avatarView.addGradient(colors: [UIColor.redGradient.start, UIColor.redGradient.end])
		gradient.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		label.text = name.prefix(1).capitalized
		label.textColor = .white
		avatarView.addSubview(label)
		label.autoCenterInSuperview()
	}

	private func setupActions() {
		avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logout)))
		myCompilationsView.showScreenAction = { [weak self] controller in
			self?.presenter.showNewScreen(with: controller)
			self?.navigationController?.navigationBar.topItem?.title = ""
			self?.navigationItem.setHidesBackButton(false, animated: true)
			self?.navigationController?.setNavigationBarHidden(false, animated: true)
		}
	}

	@objc private func logout() {
		presenter.logout()
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
		setupAvatarView(with: user.username)
		discoveryView.loadDiscovery(userId: user.id)
		myCompilationsView.loadMyCompilations(userId: user.id)
	}
}

extension MainMenuViewController: Draggable {}
