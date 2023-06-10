//
//  MyCompilationsView.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.05.2023.
//

import Foundation
import UIKit

protocol MyCompilationsViewProtocol: UIView {
	func loadMyCompilations(userId: Int)
	func didReceivedMyCompilations(compilations: [Compilation])
	func didReceivedError()
	var showScreenAction: ((UIViewController) -> Void)? { get set }
}

class MyCompilationsView: UIView {

	private enum State {
		case loading
		case error
		case content([Compilation])
		case empty
	}

	private var presenter: MyCompilationsPresenterProtocol

	private let compilationsLabel: UILabel = {
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

	private var myCompilationsStack = UIStackView()

	private let loadingStack: UIStackView = {
		let stack = UIStackView()
		stack.spacing = 8
		stack.axis = .vertical
		for _ in 0...2 {
			let loadingView = BigCompilationLoadingView()
			stack.addArrangedSubview(loadingView)
		}
		stack.distribution = .fillEqually
		return stack
	}()

	private let showMoreButton: UIButton = {
		let button = UIButton(type: .system)
		var configuration = UIButton.Configuration.plain()
		configuration.imagePlacement = .trailing
		configuration.imagePadding = 8
		button.configuration = configuration
		button.tintColor = .mainColor
		button.setTitle("Показать больше", for: .normal)
		button.setTitleColor(.mainColor, for: .normal)
		button.setImage(UIImage(systemName: "chevron.forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
		button.backgroundColor = .white
		return button
	}()

	private var showMoreButtonConstraint: NSLayoutConstraint?

	private let errorButton: UIButton = {
		let button = UIButton(type: .system)
		var configuration = UIButton.Configuration.plain()
		configuration.imagePadding = 8
		button.configuration = configuration
		button.tintColor = .defaultButtonText
		button.setTitle("Попробовать снова", for: .normal)
		button.setTitleColor(.defaultButtonText, for: .normal)
		button.setImage(CoffilationImage.refresh?.withRenderingMode(.alwaysTemplate), for: .normal)
		button.backgroundColor = .mainColor
		return button
	}()

	private var retryAction: (() -> Void)?

	private var makeCompilationButtonAction: ((UIViewController) -> Void)?

	init(presenter: MyCompilationsPresenterProtocol) {
		self.presenter = presenter
		super.init(frame: .zero)
		setupLayout()

		errorButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
		createButton.addTarget(self, action: #selector(makeCompilationButtonTapped), for: .touchUpInside)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		showMoreButton.roundCorners(corners: .allCorners, radius: 10, rect: showMoreButton.bounds)
		errorButton.roundCorners(corners: .allCorners, radius: 10, rect: errorButton.bounds)
	}

	private func setupLayout() {
		addSubview(compilationsLabel)
		compilationsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
		compilationsLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 14)
		compilationsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

		addSubview(createButton)
		createButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
		createButton.autoPinEdge(toSuperviewEdge: .top, withInset: 14)
		createButton.autoPinEdge(.left, to: .right, of: compilationsLabel)
		createButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		createButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		createButton.autoMatch(.height, to: .height, of: compilationsLabel)

		addSubview(errorButton)
		errorButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		errorButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
		errorButton.autoPinEdge(.top, to: .bottom, of: compilationsLabel, withOffset: 12)
		errorButton.autoSetDimension(.height, toSize: 48)

		addSubview(loadingStack)
		loadingStack.autoPinEdgesToSuperviewEdges(with: .init(top: 0, left: 16, bottom: 0, right: 16), excludingEdge: .top)
		loadingStack.autoPinEdge(.top, to: .bottom, of: compilationsLabel, withOffset: 12)

		addSubview(showMoreButton)
		showMoreButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		showMoreButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
		showMoreButton.autoSetDimension(.height, toSize: 48)
	}

	private func updateState(_ state: State) {
		UIView.animateKeyframes(withDuration: 0.5, delay: 0) {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
				self.errorButton.layer.opacity = 0
				self.errorButton.isHidden = true
				self.loadingStack.layer.opacity = 0
				self.loadingStack.isHidden = true
				self.myCompilationsStack.alpha = 0
				self.myCompilationsStack.isHidden = true
				self.showMoreButton.isHidden = true
			}
			UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
				switch state {
				case .loading:
					self.loadingStack.layer.opacity = 1
					self.loadingStack.isHidden = false
				case .error:
					self.errorButton.layer.opacity = 1
					self.errorButton.isHidden = false
				case .content(let compilations):
					self.myCompilationsStack = self.makeMyCompilationsStack(with: compilations)
					self.addSubview(self.myCompilationsStack)
					self.myCompilationsStack.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
					self.myCompilationsStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
					self.myCompilationsStack.autoPinEdge(.top, to: .bottom, of: self.compilationsLabel, withOffset: 12)
					self.showMoreButtonConstraint = compilations.count > 3
					? self.myCompilationsStack.autoPinEdge(.bottom, to: .top, of: self.showMoreButton, withOffset: -8)
					: nil
					self.myCompilationsStack.layer.opacity = 1
				case .empty:
					self.errorButton.layer.opacity = 0
					self.errorButton.isHidden = true
					self.loadingStack.layer.opacity = 0
					self.loadingStack.isHidden = true
					self.myCompilationsStack.alpha = 0
					self.myCompilationsStack.isHidden = true
				}
			}
		}
	}

	private func makeMyCompilationsStack(with compilations: [Compilation]) -> UIStackView {
		let stack = UIStackView()
		stack.spacing = 8
		stack.axis = .vertical
		let count = compilations.count > 3 ? 3 : compilations.count
		for compilation in compilations[0..<count] {
			let compilationView = BigCompilationView()
			compilationView.configure(
				name: compilation.name,
				description: compilation.description,
				gradient: [compilation.gradient.startColor, compilation.gradient.endColor]
			)
			stack.addArrangedSubview(compilationView)
		}
		showMoreButton.isHidden = compilations.count <= 3
		stack.distribution = .fillEqually
		return stack
	}

	@objc private func retryButtonTapped() {
		retryAction?()
	}

	@objc private func makeCompilationButtonTapped() {
		makeCompilationButtonAction?(presenter.createCompilationEditScreen())
	}
}

extension MyCompilationsView: MyCompilationsViewProtocol {
	var showScreenAction: ((UIViewController) -> Void)? {
		get { makeCompilationButtonAction }
		set { makeCompilationButtonAction = newValue }
	}

	func loadMyCompilations(userId: Int) {
		updateState(.loading)
		presenter.requestMyCompilations(userId: userId)
		retryAction = { [weak self] in
			self?.updateState(.loading)
			self?.presenter.requestMyCompilations(userId: userId)
		}
	}

	func didReceivedMyCompilations(compilations: [Compilation]) {
		updateState(.content(compilations))
	}

	func didReceivedError() {
		updateState(.error)
	}
}
