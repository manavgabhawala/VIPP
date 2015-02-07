//
//  LoginViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/7/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{
	@IBOutlet var tableView : UITableView!
	var tableCells = [UITableViewCell]()
	var emailTextField : UITextField!
	var passwordTextField : UITextField!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		tableView.tableFooterView = view
		let emailCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		emailCell.drawWithLabel("Email ID", andPlaceholder: "person@email.com", keyboardType: .EmailAddress, delegate: self)
		emailCell.top = true
		emailTextField = emailCell.textField
		
		let passwordCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		passwordCell.drawWithLabel("Password", andPlaceholder: "Min 6 Characters", keyboardType: .Default, delegate: self)
		passwordCell.textField.secureTextEntry = true
		passwordCell.textField.font = UIFont.systemFontOfSize(15)
		passwordCell.textField.returnKeyType = .Done
		passwordCell.bottom = true
		passwordTextField = passwordCell.textField
		
		tableCells.append(emailCell)
		tableCells.append(passwordCell)
	}
	
	@IBAction func backButtonPressed(sender: UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func nextButtonPressed(sender: UIButton)
	{
		login()
	}
	func login()
	{
		let email = emailTextField.text
		let password = passwordTextField.text
		var isValid = true
		if (!email.isValidEmail())
		{
			tableCells[0].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (Array(password).count < 6)
		{
			tableCells[1].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (isValid)
		{
			PFUser.logInWithUsernameInBackground(email, password: password, block: {(user, error) in
				if (user != nil && error == nil)
				{
					//TODO: User has logged in
				}
				else
				{
					self.tableCells[1].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
				}
			})
		}
	}
}
extension LoginViewController : UITableViewDelegate, UITableViewDataSource
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 2
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if section == 1
		{
			return 1
		}
		return tableCells.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		if indexPath.section == 1
		{
			return tableView.dequeueReusableCellWithIdentifier("termsLabel") as UITableViewCell
		}
		return tableCells[indexPath.row]
	}
	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
	{
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		return view
	}
}
extension LoginViewController : UITextFieldDelegate
{
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		textField.resignFirstResponder()
		if (textField == emailTextField)
		{
			passwordTextField.becomeFirstResponder()
		}
		else
		{
			login()
		}
		return true
	}
}