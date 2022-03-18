//
//  SettingsViewLayoutView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol SettingsViewLayoutViewLogic: AnyObject {
	func userPressedOnCellType(cellType: Settings.SettingsListCellType)
}

protocol SettingsViewLayoutViewDataLogic: AnyObject {
	func updateData(data: [Settings.SettingsList.ViewModel.DisplayedSettingsCell])
	func dismissAnyActiveCell()
}

class SettingsViewLayoutView: UIView, UITableViewDataSource, UITableViewDelegate, SettingsCellSwitchLogic, SettingsViewLayoutViewDataLogic {

	weak var controller: SettingsViewLayoutViewLogic? 

	@IBOutlet var baseView: UIView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var tableViewTopShadow: UIImageView!
	@IBOutlet var tableViewBottomShadow: UIImageView!

	var selectedCellIndexPath: IndexPath?
	
	var data = [Settings.SettingsList.ViewModel.DisplayedSettingsCell]()

	// MARK: View lifecycle

	override init(frame: CGRect) {
   	super.init(frame: frame)
		setup()
  	}

  	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
    	setup()
	}

	private func setup() {
		Bundle.main.loadNibNamed("SettingsViewLayoutView", owner: self, options: nil)
		addSubview(baseView)
		baseView.frame = self.bounds
		
		self.translatesAutoresizingMaskIntoConstraints = false
		baseView.translatesAutoresizingMaskIntoConstraints = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableViewTopShadow.translatesAutoresizingMaskIntoConstraints = false
		tableViewBottomShadow.translatesAutoresizingMaskIntoConstraints = false

		tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		tableViewTopShadow.heightAnchor.constraint(equalToConstant: 3).isActive = true
		tableViewTopShadow.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableViewTopShadow.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableViewTopShadow.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true

		tableViewBottomShadow.heightAnchor.constraint(equalToConstant: 3).isActive = true
		tableViewBottomShadow.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableViewBottomShadow.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableViewBottomShadow.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 1).isActive = true

		baseView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		baseView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		tableView.delegate = self
    	tableView.dataSource = self
    	tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 12, right: 0)
    	let nib = UINib(nibName: "SettingsListCell", bundle: nil)
    	tableView.register(nib, forCellReuseIdentifier: "cell")
    	tableView.backgroundColor = .white
  	}

  	// MARK: Table view

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let cell = tableView.dequeueReusableCell(
		   withIdentifier: "cell",
		   for: indexPath
		) as? SettingsListCell {
			let aData = self.data[indexPath.row]
			cell.selectionStyle = .none
			cell.controller = self
			cell.titleLabel.text = aData.title.localized()
			cell.descriptionLabel.text = aData.description.localized()

			cell.aSwitch.isUserInteractionEnabled = true

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				cell.aSwitch.isOn = aData.toggleStatus
			}

			cell.setSwitch(asVisible: aData.shouldShowToggle, accessoryVisible: aData.shouldShowAccessory)
			
			if self.data.count == 1 {
				cell.setAsCellType(cellType: .single)
			} else {
				if self.data.first == aData {
					cell.setAsCellType(cellType: .top)
				} else if self.data.last == aData {
					cell.setAsCellType(cellType: .bottom)
				} else {
					cell.setAsCellType(cellType: .middle)
				}
			}
			return cell
		} else {
			// Problem
			return UITableViewCell()
		}
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedCellIndexPath = indexPath
		let aData = self.data[indexPath.row]
		controller?.userPressedOnCellType(cellType: aData.settingsListCellType)

	}

  	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		adjustVisibilityOfShadowLines()
	}

	// MARK: Functions

	private func adjustVisibilityOfShadowLines() {
		let alfa = min(50, max(0, tableView.contentOffset.y+15))/50.0
		tableViewTopShadow.alpha = alfa
		let value = tableView.contentOffset.y + tableView.frame.size.height - tableView.contentInset.bottom - tableView.contentInset.top
		let alfa2 = min(50, max(0, tableView.contentSize.height-value-15))/50.0
		tableViewBottomShadow.alpha = alfa2
	}	

	// MARK: SettingsCellSwitchLogic 

	func switchWasPressedOnTableViewCell(cell: SettingsListCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			let aData = self.data[indexPath.row]
			controller?.userPressedOnCellType(cellType: aData.settingsListCellType)
		}
	}

	// MARK: SettingsViewLayoutViewDataLogic

	func updateData(data: [Settings.SettingsList.ViewModel.DisplayedSettingsCell]) {
		if self.data != data {
			self.data = data
			tableView.reloadData()
		}
	}

	func dismissAnyActiveCell() {
		if let indexPath = selectedCellIndexPath {
			self.tableView.deselectRow(at: indexPath, animated: true)
		}

		selectedCellIndexPath = nil
	}
}
