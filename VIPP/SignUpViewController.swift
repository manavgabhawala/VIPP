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
	
	var rawValue : Int!
	{
		get
		{
			switch self
			{
				case .FirstName, .EmailID:
					return 0
				case .LastName, .Mobile:
					return 1
				case .City, .Password:
					return 2
				case .State:
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
	
	var currentPage = 0
	private var userData = UserInfo()
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().statusBarStyle = .Default
		createAllCells()
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		tableView.tableFooterView = view
		
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
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
		return false
	}
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
		
		if (!verifyAddress(city: textFields[TextField.City.rawValue].text, state: textFields[TextField.State.rawValue].text, zip: textFields[TextField.Zip.rawValue].text.toInt()))
		{
			tableCells[0].filter{ $0 is AddressCell }.first!.contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		return isValid
	}
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
			tableCells[1][TextField.EmailID.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		if Array(textFields[TextField.Password.rawValue].text).count < 6
		{
			tableCells[1][TextField.Password.rawValue].contentView.subviews.map { ($0 as UIView).shakeForInvalidInput() }
			isValid = false
		}
		return isValid
	}
	func verifyAddress(#city: String, state: String, zip: Int?) -> Bool
	{
		if (zip == nil || city.isEmpty || state.isEmpty || zip! < 10000 || zip! >= 100000)
		{
			return false
		}
		let string = "https://maps.googleapis.com/maps/api/geocode/json?components=country:US|locality:\(city)|adminstrative_area:\(state)|postal_code:\(zip!)"
		//let URL = NSURL(scheme: "https", host: "maps.googleapis.com", path: "maps/api/geocode/json")
		let components = NSURLComponents()
		components.scheme = "https"
		components.host = "maps.googleapis.com"
		components.path = "/maps/api/geocode/json"
		components.query = "components=country:US|locality:\(city)|adminstrative_area:\(state)|postal_code:\(zip!)"
		let URL = components.URL!
		
		let request = NSURLRequest(URL: URL)
		var response : NSURLResponse?
		var error : NSError?
		if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
		{
			if (error == nil && response != nil)
			{
				let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as NSDictionary
				if dictionary.objectForKey("status") as String == "OK"
				{
					if let array = dictionary.objectForKey("results") as? [NSDictionary]
					{
						let internalDictionary = array.first!
						if let mostInternalDictionary = internalDictionary.objectForKey("geometry")?.objectForKey("location") as? NSDictionary
						{
							userData.latitude = mostInternalDictionary.objectForKey("lat") as Double
							userData.longitude = mostInternalDictionary.objectForKey("lng") as Double
						}
					}
					return true
				}
			}
			else
			{
				//TODO: Show UIAlertController
			}
		}
		return false
	}
	@IBAction func nextButton()
	{
		let maxPage = tableCells.count
		if (validateCells())
		{
			if (currentPage == 0)
			{
				userData.firstName = textFields[TextField.FirstName.rawValue].text
				userData.lastName = textFields[TextField.LastName.rawValue].text
				userData.city = textFields[TextField.City.rawValue].text
				userData.state = textFields[TextField.State.rawValue].text
				userData.zipCode = textFields[TextField.Zip.rawValue].text.toInt()!
			}
			if (currentPage + 1 < maxPage)
			{
				textFields.removeAll(keepCapacity: false)
				++currentPage
				textFields = tableCells[currentPage].map { ($0 as SignUpTableCell).textField }
				tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
			}
			else
			{
				let user = PFUser()
				user.username = textFields[TextField.EmailID.rawValue].text
				user.password = textFields[TextField.Password.rawValue].text
				user.email = textFields[TextField.EmailID.rawValue].text
				user["geoLocation"] = PFGeoPoint(latitude: userData.latitude, longitude: userData.longitude)
				user["city"] = userData.city
				user["state"] = userData.state
				user["zip"] = userData.zipCode
				user.signUpInBackgroundWithBlock({(result, error) in
					//TOOD: Decide what happens once they sign up.
				})
			}
		}
	}
}
extension SignUpViewController : UITableViewDataSource, UITableViewDelegate
{
	func createAllCells()
	{
		tableCells.removeAll(keepCapacity: false)
		let placeholders = ["Name", "Name"]//, "New York City", "NY", "10001"]
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
		textFields.append(cell.cityField)
		textFields.append(cell.stateField)
		textFields.append(cell.zipCodeField)
		cell.bottom = true
		firstCells.append(cell)
		tableCells.append(firstCells)
		
		var secondCells = [UITableViewCell]()
		let emailCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		emailCell.drawWithLabel("Email ID", andPlaceholder: "name@example.com", keyboardType: .EmailAddress, delegate: self)
		secondCells.append(emailCell)
		let phoneCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		phoneCell.drawWithLabel("Mobile", andPlaceholder: "(000) 000-0000", keyboardType: .PhonePad, delegate: self)
		phoneCell.textField.addTarget(self, action: "phoneNumberTextField:", forControlEvents: .EditingChanged)
		secondCells.append(phoneCell)
		let passwordCell = tableView.dequeueReusableCellWithIdentifier("SignUpTableCell") as SignUpTableCell
		passwordCell.drawWithLabel("Password", andPlaceholder: "You want a sample password?!?", keyboardType: .Default, delegate: self)
		passwordCell.textField.secureTextEntry = true
		secondCells.append(passwordCell)
		tableCells.append(secondCells)
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
	func phoneNumberTextField(sender: UITextField)
	{
		sender.text.makeMaskedPhoneText()
	}
}
