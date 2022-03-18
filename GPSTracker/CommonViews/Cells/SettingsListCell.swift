//
//  SettingsListCell.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol SettingsListCellDisplayLogic {
    func setSwitch(asVisible switchIsVisible: Bool, accessoryVisible: Bool)
    func setAsCellType(cellType: CellBackgroundType)
}

protocol SettingsCellSwitchLogic: AnyObject {
	func switchWasPressedOnTableViewCell(cell: SettingsListCell)
}

class SettingsListCell: FontChangeTableViewCell, SettingsListCellDisplayLogic {

	weak var controller: SettingsCellSwitchLogic? 
	public var cellBgType: CellBackgroundType = .single

	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet var selectedBackgroundImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var aSwitch: UISwitch!
	@IBOutlet weak var accessoryIconImageView: UIImageView!
	@IBOutlet weak var separatorView: UIView!

	var bgViewBottomAnchorConstraint: NSLayoutConstraint!
	var bgViewTopAnchorConstraint: NSLayoutConstraint!

	var selectedBgViewBottomAnchorConstraint: NSLayoutConstraint!
	var selectedBgViewTopAnchorConstraint: NSLayoutConstraint!
	
	var titleRightAnchorConstraint: NSLayoutConstraint!
	var descriptionRightAnchorConstraint: NSLayoutConstraint!

	// MARK: View lifecycle
	
    override func awakeFromNib() {
        super.awakeFromNib()

        aSwitch.addTarget(self, action: NSSelectorFromString("aSwitchWasPressed:"), for: .valueChanged)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        aSwitch.translatesAutoresizingMaskIntoConstraints = false
        accessoryIconImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
		selectedBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		
		backgroundImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		backgroundImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		bgViewBottomAnchorConstraint = backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		bgViewBottomAnchorConstraint.isActive = true
		bgViewTopAnchorConstraint = backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor)
		bgViewTopAnchorConstraint.isActive = true


		selectedBackgroundImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		selectedBackgroundImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		selectedBgViewBottomAnchorConstraint = selectedBackgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		selectedBgViewBottomAnchorConstraint.isActive = true
		selectedBgViewTopAnchorConstraint = selectedBackgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor)
		selectedBgViewTopAnchorConstraint.isActive = true

		
		titleLabel.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 10).isActive = true
		titleLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 6).isActive = true
		titleRightAnchorConstraint = titleLabel.rightAnchor.constraint(equalTo: accessoryIconImageView.leftAnchor, constant: -10)
		titleRightAnchorConstraint.isActive = true

		descriptionLabel.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 10).isActive = true
		descriptionRightAnchorConstraint = descriptionLabel.rightAnchor.constraint(equalTo: accessoryIconImageView.leftAnchor, constant: -10)
		descriptionRightAnchorConstraint.isActive = true
		descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
		descriptionLabel.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -9).isActive = true

		aSwitch.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true
		aSwitch.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor).isActive = true

		accessoryIconImageView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor, constant: -10).isActive = true
		accessoryIconImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
		accessoryIconImageView.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor).isActive = true

		separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		separatorView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -1).isActive = true
		separatorView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor).isActive = true
		separatorView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor).isActive = true

		selectedBackgroundImageView.alpha = 0
		
    	updateFonts()
    }

	// MARK: Functions

	private func updateFonts() {
		titleLabel.font = Font(.medium, size: .size3).font
		descriptionLabel.font = Font(.normal, size: .size5).font
	}

	@objc private func aSwitchWasPressed(_ aSwitch: UISwitch) {
		controller?.switchWasPressedOnTableViewCell(cell: self)
	}

	override func fontSizeWasChanged() {
		updateFonts()
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        UIView.animate(withDuration: animated ? 0.15 : 0, delay: 0, options: [], animations: { [weak self] in
			if selected {
				self?.selectedBackgroundImageView.alpha = 1
			} else {
				self?.selectedBackgroundImageView.alpha = 0
			}
		}, completion: { (finished: Bool) in })
    }

	// MARK: SettingsListCellDisplayLogic

	func setSwitch(asVisible switchIsVisible: Bool, accessoryVisible: Bool) {
		if switchIsVisible {
			self.aSwitch.isHidden = false
			self.accessoryIconImageView.isHidden = true
			titleRightAnchorConstraint?.constant = -45
			descriptionRightAnchorConstraint?.constant = -45
		} else {
			self.aSwitch.isHidden = true
			self.accessoryIconImageView.isHidden = !accessoryVisible
			titleRightAnchorConstraint?.constant = -10
			descriptionRightAnchorConstraint?.constant = -10
		}
	}

	func setAsCellType(cellType: CellBackgroundType) {
		switch cellType {
			case .top:
				self.bgViewTopAnchorConstraint?.constant = 5
				self.bgViewBottomAnchorConstraint?.constant = 0
				self.separatorView.isHidden = false
				backgroundImageView.image = UIImage(named: "cell_bg_top")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_top")
			case .bottom:
				self.bgViewTopAnchorConstraint?.constant = 0
				self.bgViewBottomAnchorConstraint?.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_bottom")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_bottom")
			case .middle:
				self.bgViewTopAnchorConstraint?.constant = 0
				self.bgViewBottomAnchorConstraint?.constant = 0
				self.separatorView.isHidden = false
				backgroundImageView.image = UIImage(named: "cell_bg_middle")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_middle")
			case .single:
				self.bgViewTopAnchorConstraint?.constant = 5
				self.bgViewBottomAnchorConstraint?.constant = -5
				self.separatorView.isHidden = true
				backgroundImageView.image = UIImage(named: "cell_bg_single")
				selectedBackgroundImageView.image = UIImage(named: "cell_bg_selected_single")
			default:
				break
		}
	}
}
