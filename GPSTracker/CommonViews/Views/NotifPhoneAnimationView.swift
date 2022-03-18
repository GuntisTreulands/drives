//
//  NotifPhoneAnimationView.swift
//  GPS Tracker
//
//  Created by Guntis on 2022.
//  Copyright (c) 2022 . All rights reserved.
//

import UIKit

protocol NotifPhoneAnimationViewDisplayLogic {
    func startAnimating()
   	func stopAnimating()
}

class NotifPhoneAnimationView: UIView, NotifPhoneAnimationViewDisplayLogic {

	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var inactiveBgImageView: UIImageView!
	@IBOutlet weak var activeBgImageView: UIImageView!
	@IBOutlet weak var topImageView: UIImageView!
	@IBOutlet weak var notifImageView: UIImageView!

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
		Bundle.main.loadNibNamed("NotifPhoneAnimationView", owner: self, options: nil)
		addSubview(baseView)
		baseView.frame = self.bounds
		self.layoutIfNeeded()

		self.translatesAutoresizingMaskIntoConstraints = false
		baseView.translatesAutoresizingMaskIntoConstraints = false
		inactiveBgImageView.translatesAutoresizingMaskIntoConstraints = false
		activeBgImageView.translatesAutoresizingMaskIntoConstraints = false
		topImageView.translatesAutoresizingMaskIntoConstraints = false
		notifImageView.translatesAutoresizingMaskIntoConstraints = false

		inactiveBgImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		inactiveBgImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		inactiveBgImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

		activeBgImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		activeBgImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		activeBgImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

		topImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		topImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		topImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

		notifImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		notifImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		notifImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

		topImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

		notifImageView.alpha = 1
		activeBgImageView.alpha = 1

		let language = AppSettingsWorker.shared.getCurrentLanguage()

		switch language {
			case .latvian:
				notifImageView.image = UIImage(named: "notif_image_view_notif_box_lv")
			case .russian:
				notifImageView.image = UIImage(named: "notif_image_view_notif_box_ru")
			case .english:
				notifImageView.image = UIImage(named: "notif_image_view_notif_box_en")
		}

		self.layoutIfNeeded()
  	}

	// MARK: NotifPhoneAnimationViewDisplayLogic

	func startAnimating() {
		hideNotif()
	}

	func stopAnimating() {
		self.layer.removeAllAnimations()
		self.layoutIfNeeded()
  	}

	// MARK: Functions for animating

	private func shakeAnimation() {
		let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = 4
        animation.duration = 0.07
        animation.autoreverses = true
        animation.values = [5, -5]
        layer.add(animation, forKey: "shake")

		let animation2 = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation2.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation2.repeatCount = 4
        animation2.duration = 0.07
        animation2.autoreverses = true
        animation2.values = [0.02, -0.02]
        layer.add(animation2, forKey: "shake2")
	}

	private func revealNotif() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.shakeAnimation()
		}

		UIView.animate(withDuration: 0.3, delay: 1.3, options: [], animations: {
			self.activeBgImageView.alpha = 1
		}, completion: { (finished: Bool) in })

		UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
			self.notifImageView.alpha = 1
		}, completion: { (finished: Bool) in
			if finished {
				self.hideNotif()
			}
		})
	}

	private func hideNotif() {
		UIView.animate(withDuration: 0.3, delay: 2.2, options: [], animations: {
			self.activeBgImageView.alpha = 0
			self.notifImageView.alpha = 0
		}, completion: { (finished: Bool) in
			if finished {
				self.revealNotif()
			}
		})
	}
}
