//
//  SignUpTableCell.swift
//  VIPP
//
//  Created by Manav Gabhawala on 1/31/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit



class UIRoundedTableViewCell : UITableViewCell, RoundedTableCells
{
	var bottom = false
	var top = false
	@IBOutlet var mainLabel : UILabel!
	@IBOutlet var dateLabel : UILabel!
}

class SignUpTableCell: UITableViewCell, RoundedTableCells
{
	@IBOutlet var textField : UITextField!
	@IBOutlet var label : UILabel!
	var top = false, bottom = false
	
	/**
	Creates and initializes the cell with the required properties applied to the text field and other properties of the cell.
	
	:param: labelText    The text that the label should display to the user.
	:param: placeholder  The placeholder for the text field in this cell.
	:param: keyboardType The keyboard type for the text field in this cell.
	:param: delegate     The delegate for the text field in this cell.
	*/
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
	}
}

class AddressCell : UITableViewCell, RoundedTableCells
{
	@IBOutlet var cityField: UITextField!
	@IBOutlet var stateField: UITextField!
	@IBOutlet var zipCodeField : UITextField!
	var top = false, bottom = false
	/**
	This is a callback for whenever the ZipCode text field is edited.
	
	:param: sender The text field where the zipcode resides.
	*/
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
	/**
	This is a callback for whenever the State text field is edited.
	
	:param: sender The text field where the state resides.
	*/
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

class SurveyCell : UITableViewCell, RoundedTableCells
{
	@IBOutlet var textField : UITextField!
	var top = false, bottom = false
	/**
	Creates and initializes the cell with the required properties applied to the text field
	
	:param: placeholder The placeholder text for the text field.
	:param: delegate    The delegate for the text field.
	*/
	func drawWithPlaceholder(placeholder: String, delegate: UITextFieldDelegate)
	{
		textField.placeholder = placeholder
		textField.delegate = delegate
	}
}

class DateCell: UITableViewCell, RoundedTableCells, UIPickerViewDelegate
{
	var top = false, bottom = false
	@IBOutlet var datePicker : DatePicker!
	
	func draw(labelText: String, maxDate: NSDate)
	{
		datePicker.maximumDate = maxDate
		datePicker.backgroundColor = UIColor.clearColor()
		datePicker.setup()
	}
}