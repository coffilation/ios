//
//  CompilationsListCollectionCell.swift
//  coffilation
//
//  Created by Матвей Борисов on 13.06.2023.
//

import UIKit

class CompilationsListCollectionCell: UICollectionViewCell {

	private let compilationView = BigCompilationView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupLayout() {
		addSubview(compilationView)
		compilationView.autoPinEdgesToSuperviewEdges()
	}

	func configure(name: String, description: String?, gradient: [CGColor]) {
		compilationView.configure(name: name, description: description, gradient: gradient)
	}
}
