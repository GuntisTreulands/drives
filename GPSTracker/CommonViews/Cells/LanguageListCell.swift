//
//  LanguageListCell.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol LanguageListCellDisplayLogic {
	func setAsCellType(cellType: CellBackgroundType)
}

class LanguageListCell: FontChangeTableViewCell {

    public var cellBgType: CellBackgroundType = .single

	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var checkBoxImageView: UIImageView!
	@IBOutlet weak var separatorView: UIView!

	var bgViewBottomAnchorConstraint: NSLayoutConstraint!
	var bgViewTopAnchorConstraint: NSLayoutConstraint!

	// MARK: View lifecycle
	
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
		checkBoxImageView.translatesAutoresizingMaskIntoConstraints = false

		backgroundImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
		backgroundImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
		bgViewTopAnchorConstraint = backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5)
		bgViewBottomAnchorConstraint = backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
		bgViewTopAnchorConstraint.isActive = true
		bgViewBottomAnchorConstraint.isActive = true

		titleLabel.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 10).isActive = true
		titleLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 6).isActive = true
		titleLabel.rightAnchor.constraint(equalTo: checkBoxImageView.leftAnchor, constant: -10).isActive = true

		descriptionLabel.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 10).isActive = true
		descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
		descriptionLabel.rightAnchor.constraint(equalTo: checkBoxImageView.leftAnchor, constant: -10).isActive = true
		descriptionLabel.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -9).isActive = true

		checkBoxImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
		checkBoxImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
		checkBoxImageView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true
		checkBoxImageView.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor).isActive = true

		separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		separatorView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -1).isActive = true
		separatorView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor).isActive = true
		separatorView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor).isActive = true

    	updateFonts()
    }

	// MARK: Functions

	private func updateFonts() {
		titleLabel.font = Font(.medium, size: .size3).font
		descriptionLabel.font = Font(.normal, size: .size5).font
	}

	override func fontSizeWasChanged() {
		updateFonts()
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: LanguageListCellDisplayLogic

    func setAsCellType(cellType: CellBackgroundType) {
		switch cellType {
			case .top:
				self.bgViewTopAnchorConstraint.constant = 5
				self.bgViewBottomAnchorConstraint.constant = 0
				self.separatorView.isHidden = false
				backgroundImageView.image = UIImage(named: "cell_bg_top")
			case .bottom:
				self.bgViewTopAnchorConstraint.constant = 0
				self.bgViewBottomAnchorConstraint.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_bottom")
			case .middle:
				self.bgViewTopAnchorConstraint.constant = 0
				self.bgViewBottomAnchorConstraint.constant = 0
				self.separatorView.isHidden = false
				backgroundImageView.image = UIImage(named: "cell_bg_middle")
			case .single:
				self.bgViewTopAnchorConstraint.constant = 5
				self.bgViewBottomAnchorConstraint.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_single")
			default:
				break
		}
	}
}
