//
//  MapBottomSheetDataSource.swift
//  coffilation
//
//  Created by Матвей Борисов on 26.11.2022.
//

import UIKit
import UBottomSheet

class MapBottomSheetDataSource: UBottomSheetCoordinatorDataSource {
	func sheetPositions(_ availableHeight: CGFloat) -> [CGFloat] {
		return [availableHeight - 80, 0.6*availableHeight, 0.1*availableHeight]
	}

	func initialPosition(_ availableHeight: CGFloat) -> CGFloat {
		return availableHeight - 80
	}
}
