//
//  SetupAppLanguageLayoutView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol SetupAppLanguageLayoutViewLogic: AnyObject {
	func userSelectedCell(withCellDataItem item: SetupAppLanguage.GetLanguage.ViewModel.DisplayedLanguageCellItem)
	func nextButtonWasPressed()
}

protocol SetupAppLanguageLayoutViewDataLogic: AnyObject {
	func updateData(data: [SetupAppLanguage.GetLanguage.ViewModel.DisplayedLanguageCellItem])
}

class SetupAppLanguageLayoutView: FontChangeView, UITableViewDataSource, UITableViewDelegate, SetupAppLanguageLayoutViewDataLogic {
	
	@IBOutlet var baseView: UIView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var tableViewTopShadow: UIImageView!
	@IBOutlet var tableViewBottomShadow: UIImageView!
	@IBOutlet var nextButton: UIButton!
	@IBOutlet var topTitleLabel: UILabel!

	weak var controller: SetupAppLanguageLayoutViewLogic?

  	var header: UIView!

	var data = [SetupAppLanguage.GetLanguage.ViewModel.DisplayedLanguageCellItem]()

	// MARK: View lifecycle

	override init(frame: CGRect) {
   	super.init(frame: frame)
		setup()
  	}

  	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
    	setup()
	}

	func setup() {
		Bundle.main.loadNibNamed("SetupAppLanguageLayoutView", owner: self, options: nil)
		addSubview(baseView)
		baseView.frame = self.bounds

		self.translatesAutoresizingMaskIntoConstraints = false
		baseView.translatesAutoresizingMaskIntoConstraints = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableViewTopShadow.translatesAutoresizingMaskIntoConstraints = false
		tableViewBottomShadow.translatesAutoresizingMaskIntoConstraints = false
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		topTitleLabel.translatesAutoresizingMaskIntoConstraints = false

		topTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
		topTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
		topTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true


		nextButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		nextButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		nextButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10).isActive = true
		nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50).isActive = true

		nextButton.setTitleColor(UIColor(named: "DisabledButtonColor"), for: .disabled)
		nextButton.addTarget(self, action:NSSelectorFromString("nextButtonPressed"), for: .touchUpInside)


		tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: topTitleLabel.bottomAnchor, constant: 10).isActive = true
//		tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

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
    	let nib = UINib(nibName: "LanguageListCell", bundle: nil)
    	tableView.register(nib, forCellReuseIdentifier: "cell")
    	tableView.backgroundColor = .white

    	updateFonts()
  	}

  	// MARK: Table view

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(
		   withIdentifier: "cell",
		   for: indexPath
		) as? LanguageListCell {
			let aData = self.data[indexPath.row]
			cell.selectionStyle = .none
			cell.titleLabel.text = aData.languageNameInOriginalLanguage
			cell.descriptionLabel.text = aData.languageName.localized()
			
			if aData.currentlyActive == true {
				cell.checkBoxImageView.isHidden = false
			} else {
				cell.checkBoxImageView.isHidden = true
			}

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
		let aData = self.data[indexPath.row]
		controller?.userSelectedCell(withCellDataItem: aData)
	}

  	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		adjustVisibilityOfShadowLines()
	}

	// MARK: Functions

	private func updateFonts() {
		topTitleLabel.font = Font(.normal, size: .size21).font
		nextButton.titleLabel?.font = Font(.medium, size: .size21).font
	}

	override func fontSizeWasChanged() {
		updateFonts()
		tableView.reloadData()
	}

	@objc private func nextButtonPressed() {
		controller?.nextButtonWasPressed()
  	}

	private func adjustVisibilityOfShadowLines() {
		let alfa = min(50, max(0, tableView.contentOffset.y+15))/50.0
		tableViewTopShadow.alpha = alfa
		let value = tableView.contentOffset.y + tableView.frame.size.height - tableView.contentInset.bottom - tableView.contentInset.top
		let alfa2 = min(50, max(0, tableView.contentSize.height-value-15))/50.0
		tableViewBottomShadow.alpha = alfa2
	}
	
	// MARK: AppLanguageLayoutViewDataLogic

	func updateData(data: [SetupAppLanguage.GetLanguage.ViewModel.DisplayedLanguageCellItem]) {
		self.data = data
		topTitleLabel.text = "settings_app_language_title".localized()
		nextButton.setTitle("next_button_title".localized(), for: .normal)
		tableView.reloadData()
		tableView.layoutIfNeeded()
		adjustVisibilityOfShadowLines()
	}
}
