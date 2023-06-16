//
//  MainScreenCoordinator.swift
//  coffilation
//
//  Created by Матвей Борисов on 08.04.2023.
//

import Foundation
import UIKit

class MainScreenCoordinator: Coordinator {

	private let navigationController: UINavigationController
	private let dependencies: DependencyContainerProtocol

	private var oldNavigationStack = [UIViewController]()
	private var navigationStack: [UIViewController] {
		get {
			navigationController.viewControllers
		}
		set {
			navigationController.setViewControllers(newValue, animated: true)
		}
	}

	init(
		navigationController: UINavigationController = UINavigationController(),
		dependencies: DependencyContainerProtocol
	) {
		self.navigationController = navigationController
		self.dependencies = dependencies
	}

	func start() {
		let screen = MainScreenFactory.createMainScreen(
			dependencies: dependencies,
			coordinator: self
		)
		screen.loadViewIfNeeded()
		if navigationController.viewControllers.count <= 1 {
			navigationController.viewControllers.append(screen)
		} else {
			navigationController.viewControllers.insert(screen, at: 1)
		}
		navigationController.popToViewController(screen, animated: true)
		navigationController.viewControllers = [screen]
	}

	func saveNavigationStack() {
		oldNavigationStack = navigationStack
	}

	func restoreNavigationStack() {
		navigationStack = oldNavigationStack
	}

	func makeMenuScreen(delegate: MainMenuNavigationDelegate, openCompilationScreen: @escaping  (Compilation) -> Void) -> MainMenuViewController {
		MainMenuScreenFactory.makeMainMenuScreen(
			with: dependencies,
			delegate: delegate,
			openCompilationScreen: openCompilationScreen
		)
	}

	func makeCompilationOnMapScreen(
		with compilation: Compilation,
		delegate: CompilationOnMapDelegate,
		didCloseCompletion: @escaping () -> Void
	) -> CompilationOnMapViewController {
		CompilationOnMapFactory.makeCompilationOnMapScreen(
			with: compilation,
			dependencies: dependencies,
			delegate: delegate,
			didCloseCompletion: didCloseCompletion
		)
	}
}

extension MainScreenCoordinator: MapNavigationDelegateProtocol {}

extension MainScreenCoordinator: MainMenuNavigationDelegate {
	func showNewScreen(with viewController: UIViewController) {
		navigationController.pushViewController(viewController, animated: true)
	}

	func showSheetScreen(with viewController: UIViewController) {
		guard let firstController = navigationStack.first else {
			return
		}
		viewController.modalPresentationStyle = .pageSheet
		if let sheet = viewController.sheetPresentationController {
			let fractal = UISheetPresentationController.Detent.custom { _ in
				128
			}
			sheet.largestUndimmedDetentIdentifier = fractal.identifier
			sheet.preferredCornerRadius = 0
			sheet.detents = [fractal]
		}
		guard let presentationControllerDelegate = viewController as? UIAdaptivePresentationControllerDelegate else {
			return
		}
		viewController.presentationController?.delegate = presentationControllerDelegate
		firstController.present(viewController, animated: true, completion: nil)
	}
}
