//
//  SignUpTableCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 1/31/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class SignUpTableCell: UITableViewCell
{
	@IBOutlet var textField : UITextField!
	@IBOutlet var label : UILabel!
	var top = false, bottom = false
	override func layoutSubviews()
	{
		super.layoutSubviews()
		if(top && bottom)
		{
			layer.cornerRadius = 10
			layer.masksToBounds = true
		}
		else if (self.top)
		{
			let shape = CAShapeLayer()
			shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), byRoundingCorners: .TopLeft | .TopRight, cornerRadii: CGSize(width: 10, height: 10)).CGPath
			layer.mask = shape
			layer.masksToBounds = true
		}
		else if (self.bottom)
		{
			let shape = CAShapeLayer()
			shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), byRoundingCorners: .BottomLeft | .BottomRight, cornerRadii: CGSize(width: 10, height: 10)).CGPath
			layer.mask = shape
			layer.masksToBounds = true
		}
	}
	func drawWithLabel(labelText: String, andPlaceholder placeholder: String, keyboardType: UIKeyboardType, delegate: UITextFieldDelegate)
	{
		label.text = labelText
		textField.placeholder = placeholder
		textField.keyboardType = keyboardType
		textField.autocapitalizationType = .Words
		textField.autocorrectionType = .No
		textField.borderStyle = UITextBorderStyle.None
		textField.delegate = delegate
		textField.returnKeyType = UIReturnKeyType.Next
		//TODO: Other view customizations.
	}
}

class AddressCell : UITableViewCell
{
	@IBOutlet var cityField: UITextField!
	@IBOutlet var stateField: UITextField!
	@IBOutlet var zipCodeField : UITextField!
	var top = false, bottom = false
	override func layoutSubviews()
	{
		super.layoutSubviews()
		if(top && bottom)
		{
			layer.cornerRadius = 10
			layer.masksToBounds = true
		}
		else if (self.top)
		{
			let shape = CAShapeLayer()
			shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), byRoundingCorners: .TopLeft | .TopRight, cornerRadii: CGSize(width: 10, height: 10)).CGPath
			layer.mask = shape
			layer.masksToBounds = true
		}
		else if (self.bottom)
		{
			let shape = CAShapeLayer()
			shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), byRoundingCorners: .BottomLeft | .BottomRight, cornerRadii: CGSize(width: 10, height: 10)).CGPath
			layer.mask = shape
			layer.masksToBounds = true
		}
	}
	
	@IBAction func changingZipCode(sender: UITextField)
	{
		var newText = ""
		for (i, character) in enumerate(sender.text)
		{
			if (i <= 4)
			{
				if (character.isNumberVal())
				{
					newText = "\(newText)\(character)"
				}
			}
		}
		sender.text = newText
	}
	@IBAction func changingState(sender: UITextField)
	{
		var newText = ""
		for (i, character) in enumerate(sender.text)
		{
			if (i <= 1)
			{
				newText = "\(newText)\(character)"
			}
		}
		sender.text = newText.uppercaseString
	}

}