//
//  CompilationOnMapFactory.swift
//  coffilation
//
//  Created by Матвей Борисов on 14.06.2023.
//

import Foundation

struct CompilationOnMapFactory {
	static func makeCompilationOnMapScreen(
		with compilation: Compilation,
		dependencies: DependencyContainerProtocol,
		delegate: CompilationOnMapDelegate,
		didCloseCompletion: @escaping () -> Void
	) -> CompilationOnMapViewController {
		let presenter = CompilationOnMapPresenter(dependencies: dependencies)
		let view = CompilationOnMapViewController(
			presenter: presenter,
			delegate: delegate,
			compilation: compilation,
			didCloseCompletion: didCloseCompletion)
		presenter.view = view

		return view
	}
}
