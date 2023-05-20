//
//  Collection+Extension.swift
//  coffilation
//
//  Created by Матвей Борисов on 19.05.2023.
//

import Foundation

extension Collection {
	// Returns element at index or nil if index is out of range
	func elementAtIndex(_ index: Index) -> Iterator.Element? {
		let intIndex = distance(from: startIndex, to: index)
		if intIndex >= 0 && intIndex < count {
			return self[index]
		} else {
			return nil
		}
	}
}
