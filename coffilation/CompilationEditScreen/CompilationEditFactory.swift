//
//  CompilationEditFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 20.05.2023.
//

import Foundation

struct CompilationEditFactory {
	static func makeCompilationEditScreen(with dependencies: DependencyContainerProtocol) -> CompilationEditViewController {
		let presenter = CompilationEditPresenter(dependencies: dependencies)
		let controller = CompilationEditViewController(presenter: presenter)
		presenter.view = controller
		return controller
	}
}
