//
//  CompilationModel.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.05.2023.
//

import Foundation
import UIKit

struct Compilation {

	struct Gradient {
		let startColor: CGColor
		let endColor: CGColor
	}

	let id: Int
	let name: String
	let description: String?
	let isPrivate: Bool
	let owner: User
	var gradient: Gradient

	static func convert(from rawCompilation: CompilationResponseModel) -> Compilation {
		let gradient: Gradient = {
			if let startHexColor = rawCompilation.primaryColor,
			   let endHexColor = rawCompilation.secondaryColor,
			   let startColor = UIColor(hex: startHexColor),
			   let endColor = UIColor(hex: endHexColor) {
				return Gradient(startColor: startColor.cgColor, endColor: endColor.cgColor)
			} else {
				return Gradient(startColor: UIColor.purpleGradient.start, endColor: UIColor.purpleGradient.end)
			}
		}()

		return Compilation(
			id: rawCompilation.id,
			name: rawCompilation.name,
			description: rawCompilation.description,
			isPrivate: rawCompilation.isPrivate,
			owner: rawCompilation.owner,
			gradient: gradient
		)
	}
}
