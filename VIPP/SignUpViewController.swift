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
	
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().statusBarStyle = .Default
		createAllCells()
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		tableView.tableFooterView = view
		
		if let user  = PFUser.currentUser()
		{
			if (user["whenGrowsUp"] == nil)
			{
				currentPage = 2;
				backButton.hidden = true
				tableView.reloadData()
			}
			else
			{
				//TODO: Show thank you for application page.
			}
		}
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
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
		if (textFields[TextField.FirstName.rawValue].text.isEmpty)
		{
			tableCells[0][TextField.FirstName.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (textFields[TextField.LastName.rawValue].text.isEmpty)
		{
			tableCells[0][TextField.LastName.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		let addressTuple = verifyAddress(city: textFields[TextField.City.rawValue].text, state: textFields[TextField.State.rawValue].text, zip: textFields[TextField.Zip.rawValue].text.toInt())
		if (addressTuple.latitude == nil && addressTuple.longitude == nil)
		{
			tableCells[0].filter{ $0 is AddressCell }.first!.contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
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
		if (!textFields[TextField.EmailID.rawValue].text.isValidEmail())
		{
			tableCells[1][TextField.EmailID.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if Array(textFields[TextField.Mobile.rawValue].text.returnActualNumber()).count < 10
		{
			tableCells[1][TextField.Mobile.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if Array(textFields[TextField.Password.rawValue].text).count < 6
		{
			tableCells[1][TextField.Password.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if textFields[TextField.ConfirmPassword.rawValue].text != textFields[TextField.Password.rawValue].text
		{
			tableCells[1][TextField.ConfirmPassword.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
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
	This function validates the third page cells. currentPageNumber must equal 2.
	
	:returns: true if the cells all have valid data else false.
	*/
	func validateThirdScreenCells() -> Bool
	{
		assert(currentPage == 2, "Current page must be 2 to be able to validate third cells")
		var isValid = true
		if (textFields[TextField.Future.rawValue].text.isEmpty)
		{
			tableCells[1][TextField.Future.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (textFields[TextField.GuysGirls.rawValue].text.isEmpty)
		{
			tableCells[1][TextField.GuysGirls.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if (textFields[TextField.Venues.rawValue].text.isEmpty)
		{
			tableCells[1][TextField.Venues.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
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
	@IBAction func nextButton(_: UIButton)
	{
		let maxPage = tableCells.count
		if (validateCells())
		{
			if (currentPage + 1 < maxPage)
			{
				textFields.removeAll(keepCapacity: false)
				++currentPage
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
				tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
			}
			else
			{
				if (PFUser.currentUser() == nil)
				{
					let user = PFUser()
					user.username = userData.email
					user.password = userData.password
					user.email = userData.email
					user["phoneNumber"] = userData.mobile
					user["geoLocation"] = PFGeoPoint(latitude: userData.latitude, longitude: userData.longitude)
					user["city"] = userData.city
					user["state"] = userData.state
					user["zip"] = userData.zipCode
					user["whenGrowsUp"] = userData.future
					user["favoriteVenues"] = userData.venues
					user["nightLifeHabits"] = userData.guysGirls
					user["validVIPP"] = false
					user.signUpInBackgroundWithBlock({(result, error) in
						if (result && error == nil)
						{
							//TODO: Decide what happens once they sign up.
						}
						else
						{
							//TODO: Show error message for signing up.
						}
					})
				}
				else
				{
					let user = PFUser.currentUser()
					user["whenGrowsUp"] = userData.future
					user["favoriteClubs"] = userData.venues
					user["nightLifeHabits"] = userData.guysGirls
					user["validVIPP"] = false
					//TODO: Decide what happens once their account is complete.
				}
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
		textFields.removeAll(keepCapacity: false)
		--currentPage
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
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
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
		let placeholders = ["Name", "Name"]
		let labels = ["First", "Last"]
		var firstCells = [UITableViewCell]()
		for (i, placeholder) in enumerate(placeholders)
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
			cell.drawWithLabel(labels[i], andPlaceholder: placeholder, keyboardType: .NamePhonePad, delegate: self)
			textFields.append(cell.textField)
			firstCells.append(cell)
		}
		(firstCells.first? as SignUpTableCell).top = true
		let cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as AddressCell
		cell.cityField.delegate = self
		cell.stateField.delegate = self
		cell.zipCodeField.delegate = self
		textFields.append(cell.cityField)
		textFields.append(cell.stateField)
		textFields.append(cell.zipCodeField)
		cell.bottom = true
		firstCells.append(cell)
		tableCells.append(firstCells)
		
		var secondCells = [UITableViewCell]()
		let emailCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		emailCell.drawWithLabel("Email ID", andPlaceholder: "person@email.com", keyboardType: .EmailAddress, delegate: self)
		secondCells.append(emailCell)
		emailCell.top = true
		
		let phoneCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		phoneCell.drawWithLabel("Mobile", andPlaceholder: "(XXX) XXX-XXXX", keyboardType: .PhonePad, delegate: self)
		phoneCell.textField.addTarget(self, action: "phoneNumberTextField:", forControlEvents: .EditingChanged)
		secondCells.append(phoneCell)
		
		let passwordCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		passwordCell.drawWithLabel("Password", andPlaceholder: "Min 6 Characters", keyboardType: .Default, delegate: self)
		passwordCell.textField.secureTextEntry = true
		passwordCell.textField.font = UIFont.systemFontOfSize(15)
		secondCells.append(passwordCell)
		
		let confirmPasswordCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		confirmPasswordCell.drawWithLabel("Confirm Password", andPlaceholder: "Min 6 Characters", keyboardType: .Default, delegate: self)
		confirmPasswordCell.textField.secureTextEntry = true
		confirmPasswordCell.textField.font = UIFont.systemFontOfSize(15)
		confirmPasswordCell.bottom = true
		secondCells.append(confirmPasswordCell)
		tableCells.append(secondCells)
		
		let placeholderSurvey = ["When I grow up I want to be (or already am)...", "Will you be going out with guys or girls?", "Favorite Venues?"]
		var thirdCells = [UITableViewCell]()
		for (i, placeholder) in enumerate(placeholderSurvey)
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("SurveyCell") as SurveyCell
			cell.drawWithPlaceholder(placeholder, delegate: self)
			thirdCells.append(cell)
		}
		(thirdCells.first as SurveyCell).top = true
		(thirdCells.last as SurveyCell).bottom = true
		tableCells.append(thirdCells)
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
}
