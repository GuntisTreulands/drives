//
//  StatsSegmentHeaderView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol StatsSegmentHeaderViewButtonLogic: AnyObject {
	func segmentButtonIndexChanged(_ index: Int)
}

protocol StatsSegmentHeaderViewDisplayLogic {
    func setSelectedIndex(_ selectedSegmentIndex: Int)
}

class StatsSegmentHeaderView: FontChangeHeaderFooterView, StatsSegmentHeaderViewDisplayLogic {

	@IBOutlet var segmentControl: UISegmentedControl!

	weak var controller: StatsSegmentHeaderViewButtonLogic?

	// MARK: View lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

		segmentControl.translatesAutoresizingMaskIntoConstraints = false


		self.contentView.backgroundColor = .white

		segmentControl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
		segmentControl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
		segmentControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
		segmentControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true

		segmentControl.addTarget(self, action: NSSelectorFromString("segmentControlPressed"), for: .valueChanged)
		
		updateFonts()

		segmentControl.removeAllSegments()
		segmentControl.insertSegment(withTitle: "stats_average_year".localized(), at: 0, animated: false)
		segmentControl.insertSegment(withTitle: "stats_last_year".localized(), at: 0, animated: false)
		segmentControl.insertSegment(withTitle: "stats_first_year".localized(), at: 0, animated: false)
    }

	// MARK: Functions
	
	private func updateFonts() {
		segmentControl.setTitleTextAttributes([NSAttributedString.Key.font: Font(.medium, size: .size21).font], for: .normal)
	}

    override func fontSizeWasChanged() {
		updateFonts()
	}

	@objc private func segmentControlPressed() {
		controller?.segmentButtonIndexChanged(segmentControl.selectedSegmentIndex)
	}

	// MARK: StatsSegmentHeaderViewDisplayLogic
	
	func setSelectedIndex(_ selectedSegmentIndex: Int) {
		segmentControl.selectedSegmentIndex = selectedSegmentIndex
	}
}
