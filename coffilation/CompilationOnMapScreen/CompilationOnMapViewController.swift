//
//  CompilationOnMapViewController.swift
//  coffilation
//
//  Created by Матвей Борисов on 14.06.2023.
//

import Foundation
import UIKit

protocol CompilationOnMapViewProtocol: AnyObject {
	func didReceivedPlaces(places: [Place])
	func didReceivedError()
}

class CompilationOnMapViewController: UIViewController {

	private enum State {
		case loading
		case error
		case content([Place])
		case empty
	}

	private let presenter: CompilationOnMapPresenterProtocol
	private let didCloseCompletion: () -> Void
	private let compilation: Compilation
	private var places = [Place]()

	weak var delegate: CompilationOnMapDelegate?

	private let placesCollectionView: UICollectionView = {
		let collection = UICollectionView(frame: .zero, collectionViewLayout: PlacesCollectionViewFlowLayout())
		collection.showsHorizontalScrollIndicator = false
		collection.contentInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45)
		collection.decelerationRate = .fast
		collection.register(PlacesCollectionViewCell.self, forCellWithReuseIdentifier: PlacesCollectionViewCell.reuseIdentifier)
		collection.backgroundColor = .clear
		return collection
	}()

	private let errorView: ErrorView = {
		let view = ErrorView(errorLabelText: "Не удалось загрузить места", errorButtonText: "Попробовать ещё")
		view.layer.cornerRadius = 8
		view.layer.shadowColor = UIColor.shadow.cgColor
		view.layer.shadowRadius = 5
		view.layer.shadowOpacity = 1
		view.layer.shadowOffset = CGSize(width: 0, height: 5)
		view.backgroundColor = .white
		return view
	}()

	private let loadingView: SkeletonView = {
		let view = SkeletonView()
		view.layer.cornerRadius = 8
		view.layer.shadowColor = UIColor.shadow.cgColor
		view.layer.shadowRadius = 5
		view.layer.shadowOpacity = 1
		view.layer.shadowOffset = CGSize(width: 0, height: 5)
		return view
	}()

	init(
		presenter: CompilationOnMapPresenterProtocol,
		delegate: CompilationOnMapDelegate,
		compilation: Compilation,
		didCloseCompletion: @escaping () -> Void
	) {
		self.presenter = presenter
		self.delegate = delegate
		self.compilation = compilation
		self.didCloseCompletion = didCloseCompletion
		super.init(nibName: nil, bundle: nil)

		placesCollectionView.dataSource = self
		placesCollectionView.delegate = self

		setupLayout()

		errorView.retryAction = { [weak self] in
			self?.loadPlaces()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		view.backgroundColor = .clear
		view.addSubview(placesCollectionView)
		placesCollectionView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0), excludingEdge: .top)
		placesCollectionView.autoSetDimension(.height, toSize: 120)

		view.addSubview(errorView)
		errorView.autoSetDimension(.width, toSize: UIScreen.main.bounds.width - 45 * 2 - 8 * 2)
		errorView.autoAlignAxis(.horizontal, toSameAxisOf: view, withOffset: 8)
		errorView.autoAlignAxis(toSuperviewAxis: .vertical)

		view.addSubview(loadingView)
		loadingView.autoSetDimension(.height, toSize: 120)
		loadingView.autoSetDimension(.width, toSize: UIScreen.main.bounds.width - 45 * 2 - 8 * 2)
		loadingView.autoAlignAxis(.horizontal, toSameAxisOf: view, withOffset: 8)
		loadingView.autoAlignAxis(toSuperviewAxis: .vertical)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		loadPlaces()
		delegate?.configureNavigationBar(title: compilation.name, backAction: { [weak self] in
			self?.dismiss(
			animated: true,
			completion: {
				self?.didCloseCompletion()
			})
		})
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		disableDismissalRecognizers()
	}

	override func viewDidAppear(_ animated: Bool) {
		delegate?.addPointsOnMap(places: places, color: UIColor(cgColor: compilation.gradient.endColor))
		loadingView.stop()
		loadingView.start()
	}

	override func viewDidDisappear(_ animated: Bool) {
		enableDismissalRecognizers()
		didCloseCompletion()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if let layout = placesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.itemSize = CGSize(
				width: placesCollectionView.frame.width
				- placesCollectionView.contentInset.left
				- placesCollectionView.contentInset.right
				- layout.minimumInteritemSpacing * 2,
				height: placesCollectionView.frame.height
			)
		}
	}

	private func disableDismissalRecognizers() {
		presentationController?.presentedView?.layer.shadowColor = UIColor.clear.cgColor
		presentationController?.presentedView?.gestureRecognizers?.forEach {
			$0.isEnabled = false
		}
	}

	private func enableDismissalRecognizers() {
		presentationController?.presentedView?.gestureRecognizers?.forEach {
			$0.isEnabled = true
		}
	}

	private func updateState(_ state: State) {
		UIView.animateKeyframes(withDuration: 0.5, delay: 0) {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
				self.errorView.isHidden = true
				self.loadingView.isHidden = true
				self.placesCollectionView.isHidden = true
				self.loadingView.stop()
			}
			UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
				switch state {
				case .loading:
					self.loadingView.isHidden = false
					self.loadingView.stop()
					self.loadingView.start()
				case .error:
					self.errorView.isHidden = false
				case .content(let places):
					self.places = places
					self.placesCollectionView.reloadData()
					self.placesCollectionView.isHidden = false
				case .empty:
					self.errorView.isHidden = true
					self.loadingView.isHidden = true
					self.placesCollectionView.isHidden = true
				}
			}
		}
	}

	private func loadPlaces() {
		updateState(.loading)
		if let delegate {
			presenter.requestPlaces(compilationId: compilation.id, viewBox: delegate.viewBox)
		}
	}
}

extension CompilationOnMapViewController: CompilationOnMapViewProtocol {
	func didReceivedPlaces(places: [Place]) {
		updateState(.content(places))
		guard let place = places.first else { return }
		delegate?.moveToPoint(place: place)
	}

	func didReceivedError() {
		updateState(.error)
	}
}

extension CompilationOnMapViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		false
	}
}

extension CompilationOnMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		places.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: PlacesCollectionViewCell.reuseIdentifier,
			for: indexPath
		) as? PlacesCollectionViewCell else {
			return UICollectionViewCell()
		}
		let place = places[indexPath.row]
		cell.configure(with: place)
		return cell
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let centerPoint = CGPoint(
			x: placesCollectionView.frame.size.width / 2 + scrollView.contentOffset.x,
			y: placesCollectionView.frame.size.height / 2 + scrollView.contentOffset.y
		)

		guard let indexPath = placesCollectionView.indexPathForItem(at: centerPoint) else {
			return
		}

		delegate?.moveToPoint(place: places[indexPath.row])
	}
}

extension CompilationOnMapViewController: MapViewDelegate {
	func didSelectPlace(place: Place) {
		guard let index = places.firstIndex(of: place) else {
			return
		}
		let indexPath = IndexPath(row: index, section: 0)
		placesCollectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredHorizontally], animated: true)
	}
}
