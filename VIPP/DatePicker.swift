//
//  DatePicker.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/7/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

extension UIView
{
	func didAddSubview(subview: UIView)
	{
		NSNotificationCenter.defaultCenter().postNotificationName("kNotification_UIView_didAddSubview", object: self)
	}
}
class DatePicker : UIDatePicker
{
	let font = UIFont(name: "Heiti SC", size: 18)
	override func didAddSubview(subview: UIView)
	{
		super.didAddSubview(subview)
	}
	func setup()
	{
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "subviewsUpdated:", name: "kNotification_UIView_didAddSubview", object: nil)
	}
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	func updateLabels(var view: UIView)
	{
		let label = UILabel()
		let _ : [Void] = view.subviews.map {
			if $0 is UILabel
			{
				($0 as UILabel).font = self.font
			}
			else
			{
				self.updateLabels($0 as UIView)
			}
		}
	}
	func isSubview(view: UIView?) -> Bool
	{
		if (view == nil)
		{
			return false
		}
		if (view!.superview == self)
		{
			return true
		}
		return isSubview(view!.superview)
	}
	func subviewsUpdated(notification: NSNotification)
	{
		if (notification.object == nil)
		{
			return
		}
		if ((notification.object!.isKindOfClass(NSClassFromString("UIPickerTableView"))) && isSubview((notification.object as UIView)))
		{
			updateLabels(notification.object as UIView)
		}
	}
}