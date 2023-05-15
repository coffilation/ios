//
//  MainScreenBottomSheetDataSource.swift
//  coffilation
//
//  Created by Матвей Борисов on 08.04.2023.
//

import Foundation
import UBottomSheet

class MainScreenBottomSheetDataSource: UBottomSheetCoordinatorDataSource {
	func sheetPositions(_ availableHeight: CGFloat) -> [CGFloat] {
		return [availableHeight - 80, 0.6*availableHeight, 0.1*availableHeight]
	}

	func initialPosition(_ availableHeight: CGFloat) -> CGFloat {
		return availableHeight - 80
	}
}
