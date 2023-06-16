//
//  CompilationsListFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 12.06.2023.
//

import Foundation
import UIKit

struct CompilationsListFactory {
	static func makeCompilationsListScreen(
		userId: Int,
		with dependencies: DependencyContainerProtocol,
		didSelectCompilations: @escaping (Set<Compilation>) -> Void,
		openCompilationScreen: @escaping  (Compilation) -> Void
	) -> CompilationsListViewController {
		let presenter = CompilationsListPresenter(userId: userId, dependencies: dependencies, didSelectCompilations: didSelectCompilations)
		let controller = CompilationsListViewController(presenter: presenter, style: .regular, openCompilationScreen: openCompilationScreen)
		presenter.view = controller

		return controller
	}
}
