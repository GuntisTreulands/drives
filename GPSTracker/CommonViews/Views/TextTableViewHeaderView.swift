//
//  TextTableViewHeaderView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol TextTableViewHeaderViewDisplayLogic {
    func setSectionIndex(_ sectionIndex: Int)
}

class TextTableViewHeaderView: FontChangeHeaderFooterView, TextTableViewHeaderViewDisplayLogic {

	public var cellBgType: CellBackgroundType = .single

	@IBOutlet weak var titleLabel: UILabel!

	var titleLabelTopConstraint: NSLayoutConstraint!

	// MARK: View lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

		titleLabel.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.backgroundColor = .white

		titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
		titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6)

		titleLabelTopConstraint.isActive = true

		titleLabel.textColor = UIColor(named: "TitleColor")

		updateFonts()
    }

	// MARK: Functions
	
	private func updateFonts() {
		titleLabel.font = Font(.normal, size: .size3).font
	}

    override func fontSizeWasChanged() {
		updateFonts()
	}

	// MARK: TextTableViewHeaderViewDisplayLogic
	
	func setSectionIndex(_ sectionIndex: Int) {
		if sectionIndex > 0 {
			titleLabelTopConstraint.constant = 10
		} else {
			titleLabelTopConstraint.constant = 6
		}
	}
}
