//
//  InvitationsViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/15/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit
import AddressBook

class InvitationsViewController: UIViewController
{
	var facebookFriends = [(id: String(), name: String())]
	var addressBookFriends = [(name: String(), phoneNumber: String())]
	var searchQuery : String? = nil
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar : UISearchBar!
	var showFacebook = true
	var event : Event!
	
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: "UIKeyboardWillShowNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: "UIKeyboardWillHideNotification", object: nil)
		addressBookFriends.removeAll(keepCapacity: false)
		let textFields = searchBar.subviews.filter { $0 is UITextField }.map { $0 as! UITextField }
		textFields.map { $0.font = UIFont(name: "Heiti SC", size: 17.0) }
		tableView.reloadData()
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: - Actions
	@IBAction func dismissSelf(_: UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func segmentChange(sender: UISegmentedControl)
	{
		showFacebook = !Bool(sender.selectedSegmentIndex)
		if showFacebook
		{
			if PFUser.currentUser()["fbId"] == nil
			{
				//TODO: Show Connect to Facebook Button
			}
		}
		else
		{
			// If we have no address book friends:
			if addressBookFriends.count == 0
			{
				//If access is granted get stuff. Otherwise request access. 
				//That function handles showing other stuff when access is denied.
				let auth = ABAddressBookGetAuthorizationStatus()
				if auth == .Authorized
				{
					getContactNames()
				}
				else
				{
					requestABAccess()
				}
			}
		}
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
	}
	
}
extension InvitationsViewController : UITableViewDelegate, UITableViewDataSource
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if showFacebook
		{
			if let searching = searchQuery
			{
				return facebookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }.count
			}
			return facebookFriends.count
		}
		if let searching = searchQuery
		{
			return addressBookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }.count
		}
		return addressBookFriends.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		if showFacebook
		{
			let cell = tableView.dequeueReusableCellWithIdentifier("fbCell") as! InvitationCell
			cell.nameLabel.text = facebookFriends[indexPath.row].name
			if let searching = searchQuery
			{
				cell.nameLabel.text = facebookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }[indexPath.row].name
			}
			return cell
		}
		let cell = tableView.dequeueReusableCellWithIdentifier("addressCell") as! AddressBookCell
		cell.nameLabel.text = addressBookFriends[indexPath.row].name
		cell.phoneNumberLabel.text = addressBookFriends[indexPath.row].phoneNumber
		if let searching = searchQuery
		{
			let array = addressBookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }
			cell.nameLabel.text = array[indexPath.row].name
			cell.phoneNumberLabel.text = array[indexPath.row].phoneNumber
		}
		return cell
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		return 50.0
	}
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
	{
		let view = UIView()
		view.frame.size = CGSize(width: self.view.frame.width, height: searchBar.frame.height)
		view.backgroundColor = UIColor.clearColor()
		return view
	}
}
extension InvitationsViewController : UISearchBarDelegate
{
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
	{
		if searchText.isEmpty
		{
			searchQuery = nil
		}
		else
		{
			searchQuery = searchText
		}
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
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
//MARK : - AddressBook Stuff
extension InvitationsViewController
{
	func requestABAccess()
	{
		var emptyDictionary: CFDictionaryRef?
		var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
		ABAddressBookRequestAccessWithCompletion(addressBook, {success, error in
			if success
			{
				self.getContactNames();
			}
			else
			{
				// TODO: Change table view to show request access.
			}
		})
	}
	func getContactNames()
	{
		var errorRef: Unmanaged<CFError>?
		var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &errorRef).takeRetainedValue()
		var contactList = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as! [ABRecordRef]
		for record in contactList
		{
			processRecord(record)
		}
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
	}
	private func processRecord(record: ABRecordRef)
	{
		var name = ""
		if let firstName : String = extractProperty(kABPersonFirstNameProperty, fromRecord: record) as String?
		{
			name += firstName + " "
		}
		if let lastName : String = extractProperty(kABPersonLastNameProperty, fromRecord: record) as String?
		{
			name += lastName
		}
		if let phoneNumbers = extractMultivalueProperty(kABPersonPhoneProperty, fromRecord: record) as Array<MultivalueEntry<String>>?
		{
			var mobile = phoneNumbers.first?.value
			for number in phoneNumbers
			{
				if number.label?.lowercaseString == "mobile"
				{
					mobile = number.value
				}
			}
			if let mobileNumber = mobile
			{
				let contact = (name: name, phoneNumber: mobileNumber)
				addressBookFriends.append(contact)
			}
		}
	}
	private func extractMultivalueProperty<T>(property: ABPropertyID, fromRecord record: ABRecord) -> [MultivalueEntry<T>]?
	{
		var allValues = [MultivalueEntry<T>]()
		let multivalue : ABMultiValue? = extractProperty(property, fromRecord: record)
		for i in 0..<(Int(ABMultiValueGetCount(multivalue)))
		{
			if let value = ABMultiValueCopyValueAtIndex(multivalue, i).takeRetainedValue() as? T
			{
				let id : Int = Int(ABMultiValueGetIdentifierAtIndex(multivalue, i))
				let label : String? = ABMultiValueCopyLabelAtIndex(multivalue, i)?.takeRetainedValue() as! NSString as String
				allValues.append(MultivalueEntry(value: value, label: label, id: id))
			}
		}
		return (allValues.count > 0) ? allValues : nil
	}
	private func extractProperty<T>(propertyName : ABPropertyID, fromRecord record: ABRecord) -> T?
	{
		//the following is two-lines of code for a reason. Do not combine (compiler optimization problems)
		var value: AnyObject? = ABRecordCopyValue(record, propertyName)?.takeRetainedValue()
		return value as? T
	}

}
private struct MultivalueEntry<T>
{
	var value : T
	var label : String?
	let id : Int
	
	init(value: T, label: String?, id: Int)
	{
		self.value = value
		self.label = label
		self.id = id
	}
}
