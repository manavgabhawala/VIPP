//
//  InvitationsViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/15/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit
import AddressBook
import MessageUI

class InvitationsViewController: UIViewController
{
	var facebookFriends = [(id: String(), name: String())]
	var addressBookFriends = [(name: String(), phoneNumber: String())]
	var searchQuery : String? = nil
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar : UISearchBar!
	
	var showFacebook = true
	weak var event : Event!
	@IBOutlet var connectToFacebook : UIButton!
	@IBOutlet var addressBookAccess : UIImageView!
	
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
		connectToFacebook.hidden = true
		addressBookAccess.hidden = true
		showFacebook = !Bool(sender.selectedSegmentIndex)
		if showFacebook
		{
			if PFUser.currentUser()["fbId"] == nil
			{
				connectToFacebook.hidden = false
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
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: showFacebook ? .Right : .Left)
	}
	@IBAction func connectToFacebook(_: UIButton)
	{
		PFFacebookUtils.linkUser(PFUser.currentUser(), permissions: ["public_profile", "email", "user_birthday", "user_friends"], block: {(result, error) in
			FBRequestConnection.startForMeWithCompletionHandler({(connection, result, error) in
				if (error == nil)
				{
					let user = PFUser.currentUser()
					user["fbId"] = result.objectForKey("id")
					if let gender = result.objectForKey("gender") as? String
					{
						user["isFemale"] = false
						if gender == "female"
						{
							user["isFemale"] = true
						}
					}
					self.lazilyFindFacebookFriends()
					user.saveInBackgroundWithBlock(nil)
				}
				else
				{
					//TODO: Show error
					println(error)
				}
			})
		})
	}
	func lazilyFindFacebookFriends()
	{
		event.getFriendInfo({
			let fbIds = self.event.friends.filter { $0.0 }.map { $0.1 }
			let request = FBRequest.requestForMyFriends()
			request.startWithCompletionHandler {(connection, results, error) in
				if (error == nil)
				{
					let friends = ((results as! NSDictionary).objectForKey("data") as! [NSDictionary]).map { ($0.valueForKey("id") as! String, $0.valueForKey("name") as! String) }
					self.facebookFriends = friends.filter { !contains(fbIds, $0.0) }.map { (id: $0.0, name: $0.1) }
					if self.showFacebook
					{
						self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
					}
				}
				else
				{
					//TODO: Show error
					println(error)
				}
			}
		})
		
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
			if (PFUser.currentUser()["fbId"] == nil)
			{
				connectToFacebook.hidden = false
				return 0
			}
			if let searching = searchQuery
			{
				let count = facebookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }.count
				return count == 0 ? 1 : count
			}
			return facebookFriends.count == 0 ? 1 : facebookFriends.count
		}
		if ABAddressBookGetAuthorizationStatus() != .Authorized
		{
			addressBookAccess.hidden = false
			return 0
		}
		if let searching = searchQuery
		{
			let count = addressBookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }.count
			return count == 0 ? 1 : count
		}
		return addressBookFriends.count == 0 ? 1 : addressBookFriends.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		if showFacebook
		{
			if (indexPath.row < facebookFriends.count)
			{
				let cell = tableView.dequeueReusableCellWithIdentifier("fbCell") as! InvitationCell
				cell.delegate = self
				cell.event = event
				let person = facebookFriends[indexPath.row]
				cell.nameLabel.text = person.name
				cell.fbId = person.id
				if let searching = searchQuery
				{
					let searchResults = facebookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }
					if (indexPath.row < searchResults.count)
					{
						cell.nameLabel.text = searchResults[indexPath.row].name
						cell.fbId = searchResults[indexPath.row].id
					}
					else
					{
						return tableView.dequeueReusableCellWithIdentifier("noResults") as! UITableViewCell 
					}
				}
				return cell
			}
		}
		else
		{
			if (indexPath.row < addressBookFriends.count)
			{
				let cell = tableView.dequeueReusableCellWithIdentifier("addressCell") as! AddressBookCell
				cell.nameLabel.text = addressBookFriends[indexPath.row].name
				cell.phoneNumberLabel.text = addressBookFriends[indexPath.row].phoneNumber
				cell.delegate = self
				if let searching = searchQuery
				{
					let array = addressBookFriends.filter { $0.name.rangeOfString(searching, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil }
					if (indexPath.row < array.count)
					{
						cell.nameLabel.text = array[indexPath.row].name
						cell.phoneNumberLabel.text = array[indexPath.row].phoneNumber
					}
					else
					{
						return tableView.dequeueReusableCellWithIdentifier("noResults") as! UITableViewCell
					}
				}
				return cell
			}
		}
		return tableView.dequeueReusableCellWithIdentifier("noResults") as! UITableViewCell
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
		self.addressBookAccess.hidden = false
		var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
		ABAddressBookRequestAccessWithCompletion(addressBook, {success, error in
			if success
			{
				self.addressBookAccess.hidden = true
				self.getContactNames();
			}
			else
			{
				println(error)
				self.addressBookAccess.hidden = false
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
				let label : String? = ABMultiValueCopyLabelAtIndex(multivalue, i)?.takeRetainedValue() as? NSString as? String
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
//MARK: Share for non-existing users.
extension InvitationsViewController : AddressBookCellDelegate, MFMessageComposeViewControllerDelegate, InvitationCellDelegate
{
	func sendMessage(number: String?)
	{
		let messageController = MFMessageComposeViewController()
		messageController.messageComposeDelegate = self
		if let no = number
		{
			messageController.recipients = [no]
		}
		messageController.body = "Hey, I want you to attend \(event.description) with me. Join me on Vipp: https://appsto.re/us/XdqP5.i"
		presentViewController(messageController, animated: true, completion: nil)
	}
	func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult)
	{
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	func removeFacebookUser(id: String)
	{
		if let index = find(facebookFriends.map { $0.0 }, id)
		{
			facebookFriends.removeAtIndex(index)
			tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
		}
	}
}
