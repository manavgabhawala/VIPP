//
//  SignUpViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 1/30/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit
import Foundation

private struct UserInfo
{
	var firstName = ""
	var lastName = ""
	var city = ""
	var zipCode = 0
	var state = ""
	var latitude = 0.0
	var birthday = NSDate(timeIntervalSinceNow: 0)
	var longitude = 0.0
	var email = ""
	var password = ""
	var mobile = 0
	var future = ""
	var guysGirls = ""
	var venues = ""
}

enum TextField
{
	case FirstName
	case LastName
	case City
	case State
	case Zip
	case EmailID
	case Mobile
	case Password
	case ConfirmPassword
	case Future
	case GuysGirls
	case Venues
	var rawValue : Int!
	{
		get
		{
			switch self
			{
				case .FirstName, .EmailID, .Future:
					return 0
				case .LastName, .Mobile, .GuysGirls:
					return 1
				case .City, .Password, .Venues:
					return 2
				case .State, .ConfirmPassword:
					return 3
				case .Zip:
					return 4
				default:
					return nil
			}
		}
	}
}
class SignUpViewController: UIViewController
{
	var tableCells = [[UITableViewCell]()]
	
	var textFields = [UITextField]()
	
	@IBOutlet var tableView : UITableView!
	@IBOutlet var backButton : UIButton!
	
	var currentPage = 0
	private var userData = UserInfo()
	var birthdayDetailLabel : UILabel?
	
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().statusBarStyle = .Default
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: "UIKeyboardWillShowNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: "UIKeyboardWillHideNotification", object: nil)
		createAllCells()
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		tableView.tableFooterView = view
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		if let user  = PFUser.currentUser()
		{
			if (user["whenGrowsUp"] == nil)
			{
				currentPage = 1
				setTextFields()
				textFields[TextField.FirstName.rawValue].text = user["firstName"] as String
				textFields[TextField.LastName.rawValue].text = user["lastName"] as String
				backButton.hidden = true
				tableView.reloadData()
			}
			else
			{
				let finalPage = storyboard!.instantiateViewControllerWithIdentifier("FinalPage") as ThankYouViewController
				finalPage.modalPresentationStyle = .FullScreen
				finalPage.modalTransitionStyle = .FlipHorizontal
				presentViewController(finalPage, animated: false, completion: nil)
			}
		}
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	
	//MARK: - Helper Functions
	func setTextFields()
	{
		assert(currentPage >= 0 && currentPage < tableCells.count)
		let manager = NSFileManager()
		let somethigngEl = 1
		
		textFields.removeAll(keepCapacity: false)
		let signUpTextFields = tableCells[currentPage].filter{ $0 is SignUpTableCell }.map { ($0 as SignUpTableCell).textField }
		var addressTextFields = [UITextField]()
		let _ : [Void] = tableCells[currentPage].filter{ $0 is AddressCell }.map {
			let cell = ($0 as AddressCell)
			addressTextFields.append(cell.cityField)
			addressTextFields.append(cell.stateField)
			addressTextFields.append(cell.zipCodeField)
		}
		let surveyTextFields = tableCells[currentPage].filter{ $0 is SurveyCell }.map { ($0 as SurveyCell).textField }
		signUpTextFields.map { self.textFields.append($0) }
		addressTextFields.map { self.textFields.append($0) }
		surveyTextFields.map { self.textFields.append($0) }
	}
	
	//MARK: - Data Validation
	/**
	This function validates the current screen cells depedning on the current page number
	
	:returns: true if the cells all have valid data else false.
	*/
	func validateCells() -> Bool
	{
		if (currentPage == 0)
		{
			return validateFirstScreenCells()
		}
		else if (currentPage == 1)
		{
			return validateSecondScreenCells()
		}
		else if (currentPage == 2)
		{
			return validateThirdScreenCells()
		}
		return false
	}
	
	/**
	This function validates the first page cells. currentPageNumber must equal 0.
	
	:returns: true if the cells all have valid data else false.
	*/
	func validateFirstScreenCells() -> Bool
	{
		assert(currentPage == 0, "Current page must be 0 to be able to validate first cells")
		var isValid = true
		if (!textFields[TextField.EmailID.rawValue].text.isValidEmail())
		{
			tableCells[currentPage][TextField.EmailID.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if Array(textFields[TextField.Mobile.rawValue].text.returnActualNumber()).count < 10
		{
			tableCells[currentPage][TextField.Mobile.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if Array(textFields[TextField.Password.rawValue].text).count < 6
		{
			tableCells[currentPage][TextField.Password.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if textFields[TextField.ConfirmPassword.rawValue].text != textFields[TextField.Password.rawValue].text
		{
			tableCells[currentPage][TextField.ConfirmPassword.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (isValid)
		{
			userData.email = textFields[TextField.EmailID.rawValue].text
			userData.password = textFields[TextField.Password.rawValue].text
			userData.mobile = textFields[TextField.Mobile.rawValue].text.returnActualNumber().toInt()!
		}
		return isValid
	}
	/**
	This function validates the second page cells. currentPageNumber must equal 1.
	
	:returns: true if the cells all have valid data else false.
	*/
	func validateSecondScreenCells() -> Bool
	{
		assert(currentPage == 1, "Current page must be 1 to be able to validate second cells")
		var isValid = true
		if (textFields[TextField.FirstName.rawValue].text.isEmpty)
		{
			tableCells[currentPage][TextField.FirstName.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (textFields[TextField.LastName.rawValue].text.isEmpty)
		{
			tableCells[currentPage][TextField.LastName.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		let addressTuple = verifyAddress(city: textFields[TextField.City.rawValue].text, state: textFields[TextField.State.rawValue].text, zip: textFields[TextField.Zip.rawValue].text.toInt())
		if (addressTuple.latitude == nil && addressTuple.longitude == nil)
		{
			tableCells[currentPage].filter{ $0 is AddressCell }.first!.contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .MediumStyle
		if ((birthdayDetailLabel?.text?) == nil || birthdayDetailLabel!.text!.isEmpty || dateFormatter.dateFromString(birthdayDetailLabel!.text!) == nil)
		{
			
			tableCells[currentPage].filter {$0 is UIRoundedTableViewCell }.first!.contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (isValid)
		{
			userData.firstName = textFields[TextField.FirstName.rawValue].text
			userData.lastName = textFields[TextField.LastName.rawValue].text
			userData.city = textFields[TextField.City.rawValue].text
			userData.state = textFields[TextField.State.rawValue].text
			userData.zipCode = textFields[TextField.Zip.rawValue].text.toInt()!
			userData.latitude = addressTuple.latitude!
			userData.longitude = addressTuple.longitude!
			userData.birthday = dateFormatter.dateFromString(birthdayDetailLabel!.text!)!
		}
		return isValid
	}
	/**
	This function validates the third page cells. currentPageNumber must equal 2.
	
	:returns: true if the cells all have valid data else false.
	*/
	func validateThirdScreenCells() -> Bool
	{
		assert(currentPage == 2, "Current page must be 2 to be able to validate third cells")
		var isValid = true
		if (textFields[TextField.Future.rawValue].text.isEmpty)
		{
			tableCells[currentPage][TextField.Future.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (textFields[TextField.GuysGirls.rawValue].text.isEmpty)
		{
			tableCells[currentPage][TextField.GuysGirls.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (textFields[TextField.Venues.rawValue].text.isEmpty)
		{
			tableCells[currentPage][TextField.Venues.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (isValid)
		{
			userData.future = textFields[TextField.Future.rawValue].text
			userData.guysGirls = textFields[TextField.GuysGirls.rawValue].text
			userData.venues = textFields[TextField.Venues.rawValue].text
		}
		return isValid
	}
	
	//MARK: - Actions
	/**
	This function is called when the next button is pressed
	
	:param: _ The UIButton that represents next. Anonymous variable because it is unused.
	*/
	@IBAction func nextButtonPressed(_: UIButton)
	{
		let maxPage = tableCells.count
		if (validateCells())
		{
			if (currentPage + 1 < maxPage)
			{
				++currentPage
				setTextFields()
				tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
				tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
			}
			else
			{
				let message = "Placeholder text here"
				
				let alertController = UIAlertController(title: "Terms and Conditions", message: message, preferredStyle: .Alert)
				let textView = UITextView(frame: CGRect(origin: CGPoint(x: 0, y: 40), size: CGSize(width: alertController.view.frame.width, height: 150)))
				//textView.text = message
				//alertController.view.addSubview(textView)
				alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: "I Agree", style: .Default, handler: {(controller) in
					if (PFUser.currentUser() == nil)
					{
						let user = PFUser()
						user.username = self.userData.email
						user.password = self.userData.password
						user.email = self.userData.email
						user["firstName"] = self.userData.firstName
						user["lastName"] = self.userData.lastName
						user["phoneNumber"] = self.userData.mobile
						user["geoLocation"] = PFGeoPoint(latitude: self.userData.latitude, longitude: self.userData.longitude)
						user["city"] = self.userData.city
						user["state"] = self.userData.state
						user["zip"] = self.userData.zipCode
						user["birthday"] = self.userData.birthday
						user["whenGrowsUp"] = self.userData.future
						user["favoriteVenues"] = self.userData.venues
						user["nightLifeHabits"] = self.userData.guysGirls
						user["validVIPP"] = false
						user.signUpInBackgroundWithBlock({(result, error) in
							if (result && error == nil)
							{
								self.performSegueWithIdentifier("thankYou", sender: self)
							}
							else
							{
								let alertController = UIAlertController(title: "Sign Up Error", message: "There was an error signing you up. Please check all fields for valid information and that you have internet access.", preferredStyle: .Alert)
								if let message = error.userInfo?["error"] as? String
								{
									alertController.message = message
								}
								alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
								self.presentViewController(alertController, animated: true, completion: nil)
							}
						})
					}
					else
					{
						let user = PFUser.currentUser()
						user["firstName"] = self.userData.firstName
						user["lastName"] = self.userData.lastName
						user["phoneNumber"] = self.userData.mobile
						user["geoLocation"] = PFGeoPoint(latitude: self.userData.latitude, longitude: self.userData.longitude)
						user["city"] = self.userData.city
						user["state"] = self.userData.state
						user["zip"] = self.userData.zipCode
						user["birthday"] = self.userData.birthday
						user["whenGrowsUp"] = self.userData.future
						user["favoriteVenues"] = self.userData.venues
						user["nightLifeHabits"] = self.userData.guysGirls
						user["validVIPP"] = false
						user.saveInBackgroundWithBlock { (result, error) in
							if (result && error == nil)
							{
								self.performSegueWithIdentifier("thankYou", sender: self)
							}
							else
							{
								let alertController = UIAlertController(title: "Sign Up Error", message: "There was an error saving your data. Please check all fields for valid information and that you have internet access.", preferredStyle: .Alert)
								if let message = error.userInfo?["error"] as? String
								{
									alertController.message = message
								}
								alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
								self.presentViewController(alertController, animated: true, completion: nil)
							}
						}
					}
				}))
				presentViewController(alertController, animated: true, completion: nil)
			}
			backButton.hidden = false
			if (currentPage == 1 && PFUser.currentUser() != nil)
			{
				backButton.hidden = true
			}
		}
	}
	
	/**
	This function is called when the back button is pressed
	
	:param: _ The UIButton that represents next. Anonymous variable because it is unused.
	*/
	@IBAction func backButtonPressed(_: UIButton)
	{
		if (currentPage == 0)
		{
			dismissViewControllerAnimated(true, completion: nil)
			return
		}
		--currentPage
		setTextFields()
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
		tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
		backButton.hidden = false
		if (currentPage == 1 && PFUser.currentUser() != nil)
		{
			backButton.hidden = true
		}
	}
}
//MARK: - Table View Stuff
extension SignUpViewController : UITableViewDataSource, UITableViewDelegate
{
	/**
	This function creates and stores all the table view cells for all the pages.
	*/
	func createAllCells()
	{
		tableCells.removeAll(keepCapacity: false)
		var firstCells = [UITableViewCell]()
		let emailCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		emailCell.drawWithLabel("Email", andPlaceholder: "person@email.com", keyboardType: .EmailAddress, delegate: self)
		emailCell.textField.autocapitalizationType = .None
		firstCells.append(emailCell)
		let phoneCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		phoneCell.drawWithLabel("Mobile", andPlaceholder: "(XXX) XXX-XXXX", keyboardType: .PhonePad, delegate: self)
		phoneCell.textField.addTarget(self, action: "phoneNumberTextField:", forControlEvents: .EditingChanged)
		firstCells.append(phoneCell)
		let passwordCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		passwordCell.drawWithLabel("Password", andPlaceholder: "Min 6 Characters", keyboardType: .Default, delegate: self)
		passwordCell.textField.secureTextEntry = true
		passwordCell.textField.font = UIFont.systemFontOfSize(15)
		firstCells.append(passwordCell)
		let confirmPasswordCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		confirmPasswordCell.drawWithLabel("Confirm Password", andPlaceholder: "Min 6 Characters", keyboardType: .Default, delegate: self)
		confirmPasswordCell.textField.secureTextEntry = true
		confirmPasswordCell.textField.font = UIFont.systemFontOfSize(15)
		firstCells.append(confirmPasswordCell)
		(firstCells.first as RoundedTableCells).top = true
		(firstCells.last as RoundedTableCells).bottom = true
		tableCells.append(firstCells)
		
		let placeholders = ["Name", "Name"]
		let labels = ["First", "Last"]
		var secondCells = [UITableViewCell]()
		for (i, placeholder) in enumerate(placeholders)
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
			cell.drawWithLabel(labels[i], andPlaceholder: placeholder, keyboardType: .NamePhonePad, delegate: self)
			secondCells.append(cell)
		}
		(secondCells.first? as SignUpTableCell).top = true
		let birthdayCell = tableView.dequeueReusableCellWithIdentifier("DateDisplay") as UIRoundedTableViewCell
		birthdayCell.mainLabel.text = "Birthday"
		birthdayCell.dateLabel.text = "Jan 1, 1985"
		birthdayDetailLabel = birthdayCell.dateLabel
		secondCells.append(birthdayCell)
		
		let addressCell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as AddressCell
		addressCell.cityField.delegate = self
		addressCell.stateField.delegate = self
		addressCell.zipCodeField.delegate = self
		secondCells.append(addressCell)
		
		(secondCells.first as RoundedTableCells).top = true
		(secondCells.last as RoundedTableCells).bottom = true
		tableCells.append(secondCells)
		
		let placeholderSurvey = ["Profession?", "Will you be going out with guys or girls?", "Favorite Venues?"]
		var thirdCells = [UITableViewCell]()
		for (i, placeholder) in enumerate(placeholderSurvey)
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("SurveyCell") as SurveyCell
			cell.drawWithPlaceholder(placeholder, delegate: self)
			thirdCells.append(cell)
		}
		(thirdCells.first as RoundedTableCells).top = true
		(thirdCells.last as RoundedTableCells).bottom = true
		tableCells.append(thirdCells)
		setTextFields()
		tableView.reloadData()
	}
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
		return tableCells[currentPage].count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		if indexPath.section == 1
		{
			if (currentPage == 0)
			{
				return tableView.dequeueReusableCellWithIdentifier("loginCell") as UITableViewCell
			}
			return tableView.dequeueReusableCellWithIdentifier("termsLabel") as UITableViewCell
		}
		return tableCells[currentPage][indexPath.row]
	}
	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
	{
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		return view
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		textFields.map { $0.resignFirstResponder() }
		if (currentPage == 0)
		{
			if (indexPath.section == 1)
			{
				performSegueWithIdentifier("loginSegue", sender: self)
			}
		}
		if (tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "DateDisplay")
		{
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateStyle = .MediumStyle
			let newIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
			if (tableView.cellForRowAtIndexPath(newIndexPath) is DateCell)
			{
				tableCells[currentPage].removeAtIndex(indexPath.row + 1)
				tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
			}
			else
			{
				let birthdayCell = tableView.dequeueReusableCellWithIdentifier("DateCell") as DateCell
				birthdayCell.draw("Birthday", maxDate: NSDate(timeIntervalSinceNow: 0))
				if let date = dateFormatter.dateFromString(birthdayDetailLabel!.text!)
				{
					birthdayCell.datePicker.setDate(date, animated: true)
				}
				birthdayCell.datePicker.addTarget(self, action: "datePicked:", forControlEvents: .ValueChanged)
				tableCells[currentPage].insert(birthdayCell, atIndex: indexPath.row + 1)
				tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
			}
		}
	}
}
//MARK: - TextField Stuff
extension SignUpViewController : UITextFieldDelegate
{
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		textField.resignFirstResponder()
		let index = find(textFields, textField)!
		if (textFields.count > index + 1)
		{
			textFields[index+1].becomeFirstResponder()
		}
		else
		{
			nextButtonPressed(UIButton())
		}
		return true
	}
	
	/**
	A function callback for everytime the phone number text field is edited so that it can update the phone number to the correct format.
	
	:param: sender The text field where the phone number is being entered.
	*/
	func phoneNumberTextField(sender: UITextField)
	{
		sender.text.makeMaskedPhoneText()
	}
	
	/**
	A registered notification callback for when the keyboard is shown because the user tapped on a textfield.
	
	:param: notification The notification that the keyboard is now shown.
	:discussion: This function deals with creating an offset for the scroll view whenever the keyboard is shown so that the view does not think that it has the entire screen to draw in rather it has the screen minus the height of the keyboard.
	*/
	func keyboardShown (notification: NSNotification)
	{
		var info = notification.userInfo!
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
		{
			var contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
			tableView.contentInset = contentInsets
			tableView.scrollIndicatorInsets = contentInsets
			var rect = self.view.frame
			rect.size.height -= keyboardSize.height
			var activeField = UIView()
			for textField in textFields
			{
				if textField.isFirstResponder()
				{
					activeField = textField
					break
				}
			}
			if (!rect.contains(activeField.frame.origin))
			{
				tableView.scrollRectToVisible(activeField.frame, animated: true)
			}
		}
	}
	
	/**
	A registered notification callback for when the keyboard is shown because the textfields lost responder.
	
	:param: notification The notification that the keyboard is now hidden.
	:discussion: This function deals with removing the offset created for the scroll view whenever the keyboard is hidden so that now the view knows that it has the entire screen to draw on again.
	*/
	func keyboardHidden (notification: NSNotification)
	{
		var contentInsets = UIEdgeInsetsZero
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
	}
}
extension SignUpViewController
{
	/**
	This is a callback for whenever the date picker changes it's date.
	
	:param: datePicker The date picker whose date changed
	*/
	func datePicked(datePicker: DatePicker)
	{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .MediumStyle
		if (birthdayDetailLabel != nil)
		{
			birthdayDetailLabel?.text = dateFormatter.stringFromDate(datePicker.date)
		}
	}
}