//
//  Extensions.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/1/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

extension UIView
{
	/**
	This is an extension to UIView which will create a standard shake animation to indicate to the user that something went wrong.
	
	:see: shake:
	*/
	func shakeForInvalidInput()
	{
		shake(iterations: 7, direction: 1, currentTimes: 0, size: 10, interval: 0.1)
		if (self is UITextField)
		{
			if ((self as! UITextField).secureTextEntry)
			{
				(self as! UITextField).text = ""
			}
		}
	}
	
	/**
	This function shakes a UIView with a spring timing curve using the parameters to create the animations.
	
	:param: iterations   The number of times to shake the view back and forth before stopping
	:param: direction    The direction in which to move the view for the first time
	:param: currentTimes The number of times the function has been performed. Use 0 to begin with.
	:param: size         The size of the shake. i.e. how much to move the view
	:param: interval     The amount of time for each 'shake'.
	*/
	func shake(#iterations: Int, direction: Int, currentTimes: Int, size: CGFloat, interval: NSTimeInterval)
	{
		UIView.animateWithDuration(interval, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 10, options: .allZeros, animations: {() in
			self.transform = CGAffineTransformMakeTranslation(size * CGFloat(direction), 0)
			}, completion: {(finished) in
				if (currentTimes >= iterations)
				{
					UIView.animateWithDuration(interval, animations: {() in
						self.transform = CGAffineTransformIdentity
					})
					return
				}
				self.shake(iterations: iterations - 1, direction: -direction, currentTimes: currentTimes + 1, size: size, interval: interval)
		})
	}
}

extension Character
{
	/**
	This function checks if the character represents a number or not.
	
	:returns: true if the string is a number else it is false.
	*/
	func isNumberVal() -> Bool
	{
		let characterSet: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
		return characterSet.filter { $0 == self}.count > 0
	}
}
extension String
{
	/**
	*  This subscript function gives quick access to a String's character with the position passed in by the substring.
	:Code: var myString = "Hello World"
	myString[4] //returns "o"
	:Returns: A string with the character at the index passed in through the subscript.
	:Warning: This function returns an empty String if the index is out of bounds.
	*/
	subscript (i: Int) -> String
		{
			if count(self) > i
			{
				return String(Array(self)[i])
			}
			return ""
	}
	/**
	A quick access function that creates a String.Index object which is required in Swift instead of just an index.
	
	:param: theInt The index value that you want the String.Index to refer to.
	
	:returns: The return value is a String.Index object which has the index you would like.
	*/
	func indexAt(theInt: Int) -> String.Index
	{
		return advance(self.startIndex, theInt)
	}
	
	/**
	This function is performed on a string and removes all the formatting/unnecessary characters and returns a String with just numbers in it. This is useful for formatting prices, phone numbers, etc.
	
	:returns: The string with just numbers in it.
	*/
	func returnActualNumber() -> String
	{
		var returnString = stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
		returnString = returnString.stringByReplacingOccurrencesOfString(" ", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString("-", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString("(", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString(")", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString("+", withString: "")
		return returnString
	}
	/**
	This function can be performed on a string to make a masked string which has number formattings such as +, (, ) and -'s.
	
	:returns: Returns a string that contains the number masked to be in a correct format.
	*/
	mutating func makeMaskedPhoneText()
	{
		//Trims non-numerical characters
		self = self.returnActualNumber()
		
		//Formats mobile number with parentheses and spaces
		if (count(self) <= 10)
		{
			if (count(self) > 6)
			{
				self = self.stringByReplacingCharactersInRange(Range<String.Index>(start: self.indexAt(6), end: self.indexAt(6)), withString: "-")
			}
			if (count(self) > 3)
			{
				self = self.stringByReplacingCharactersInRange(Range<String.Index>(start: self.indexAt(3), end: self.indexAt(3)), withString: ") ")
			}
			if (count(self) > 0)
			{
				self = self.stringByReplacingCharactersInRange(Range<String.Index>(start: self.indexAt(0), end: self.indexAt(0)), withString: "(")
			}
		}
		else
		{
			var remainder = (self as NSString).substringFromIndex(count(self) - 10)
			remainder.makeMaskedPhoneText()
			self = "+" + ((self as NSString).substringToIndex(count(self) - 10) as String) + " " + (remainder)
		}
	}
	func isValidEmail() -> Bool
	{
		if (self.isEmpty)
		{
			return false;
		}
		let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
		return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
	}
	/**
	This function generates a random alphanumeric code and returns it.
	
	:param: len The length of the rand string to create
	
	:returns: The generated alphanumeric code generated.
	*/
	static func randomStringWithLength (len : Int) -> String
	{
		let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		var randomString = ""
		for i in 0..<len
		{
			var randIndex : Int = Int(arc4random_uniform(UInt32(Array(letters).count)))
			randomString += "\(Array(letters)[randIndex])"
		}
		return randomString
	}
	/**
	Capitalizes a string using sentence case.
	
	:returns: A sentence cased copy of self.
	*/
	func sentenceCapitalizedString() -> String
	{
		var formattedString = ""
		let range = Range(start: self.startIndex, end: self.endIndex)
		self.enumerateSubstringsInRange(range, options: .BySentences, {(sentence, sentenceRange, enclosingRange, stop) in
			formattedString += sentence.stringByReplacingCharactersInRange(Range(start: self.startIndex, end: advance(self.startIndex, 1)), withString: sentence[0].uppercaseString)
		})
		if (formattedString[count(formattedString) - 1] != ".")
		{
			formattedString += "."
		}
		return formattedString
	}
}

/**
*  This protocol must be used by any cell that is a part of a table with rounded corners.
*/
@objc protocol RoundedTableCells
{
	var bottom : Bool { set get }
	var top : Bool { set get }
}
extension UITableViewCell
{
	/**
	This function is used to make the table view have rounded corners.
	*/
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		if (self is RoundedTableCells)
		{
			let radius : CGFloat = 5.0
			if((self as! RoundedTableCells).top && (self as! RoundedTableCells).bottom)
			{
				layer.cornerRadius = radius
				layer.masksToBounds = true
			}
			else if ((self as! RoundedTableCells).top)
			{
				let shape = CAShapeLayer()
				shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), byRoundingCorners: .TopLeft | .TopRight, cornerRadii: CGSize(width: radius, height: radius)).CGPath
				layer.mask = shape
				layer.masksToBounds = true
			}
			else if ((self as! RoundedTableCells).bottom)
			{
				let shape = CAShapeLayer()
				shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), byRoundingCorners: .BottomLeft | .BottomRight, cornerRadii: CGSize(width: radius, height: radius)).CGPath
				layer.mask = shape
				layer.masksToBounds = true
			}
			if !(self as! RoundedTableCells).bottom
			{
				let mySeparator = UIView(frame: CGRect(x: contentView.frame.size.width * 0.025, y: contentView.frame.size.height - 1, width: contentView.frame.size.width * 0.95, height: 1))
				mySeparator.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
				contentView.addSubview(mySeparator)
			}
		}
		layoutIfNeeded()
	}
}
func verifyAddress(#city: String, #state: String, #zip: Int?) -> (latitude: Double?, longitude: Double?)
{
	if (zip == nil || city.isEmpty || state.isEmpty || zip! < 10000 || zip! >= 100000)
	{
		return (nil, nil)
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
			let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as! NSDictionary
			if dictionary.objectForKey("status") as! String == "OK"
			{
				if let array = dictionary.objectForKey("results") as? [NSDictionary]
				{
					let internalDictionary = array.first!
					if let mostInternalDictionary = internalDictionary.objectForKey("geometry")?.objectForKey("location") as? NSDictionary
					{
						let latitude = mostInternalDictionary.objectForKey("lat") as! Double
						let longitude = mostInternalDictionary.objectForKey("lng") as! Double
						return (latitude, longitude)
					}
				}
			}
		}
	}
	return (nil, nil)
}

class DatePicker : UIDatePicker
{
	let font = UIFont(name: "Heiti SC", size: 18)
	func setup()
	{
		subviews.filter { $0 is UILabel} .map { self.updateLabels($0 as! UIView) }
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "subviewsUpdated:", name: "kNotification_UIView_didAddSubview", object: nil)
	}
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	func updateLabels(var view: UIView)
	{
		let _ : [Void] = view.subviews.map {
			if $0 is UILabel
			{
				($0 as! UILabel).font = self.font
			}
			else
			{
				self.updateLabels($0 as! UIView)
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
		if ((notification.object!.isKindOfClass(NSClassFromString("UIPickerTableView"))) && isSubview((notification.object as! UIView)))
		{
			updateLabels(notification.object as! UIView)
		}
	}
}
extension UIAlertController
{
	/**
	A quick access function that returns an instance of a UIAlertController with the generic title an Error occured.
	:param: title
	:param: message An optional string which is the message that will be displayed. If the string is a nil the default message: "An error occurred while loading the data from the internet. Please check your internet connection and try again." will be displayed.
	:param: error An optional error whose value will take precedence over the message specified.
	:return: This function returns a UIAlertController instance with a dismiss action provided and can directly be displayed using the presentViewController function.
	*/
	class func errorAlertController(title tit: String?, message msg: String?, error: NSError?) -> UIAlertController
	{
		let title = tit ?? "An Error Occurred"
		let message = error?.userInfo?["error"] as? String ?? msg ?? "An error occurred while communicating with our servers. Please check that you have a valid internet connection and try again."
		let alertController = UIAlertController(title: title.sentenceCapitalizedString(), message: message.sentenceCapitalizedString(), preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
		return alertController
	}
}
var profilePictureLocation : String = ""

public func < (lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedAscending
}

func isConnectedToInternet() -> Bool
{
	let zero : Int8 = 0
	//var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
	var zeroAddress = sockaddr_in();
	zeroAddress.sin_len = UInt8(sizeof(sockaddr_in.Type))
	zeroAddress.sin_family = UInt8(AF_INET)
	zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
	zeroAddress.sin_family = sa_family_t(AF_INET)
	
	let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
		SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
	}
	
	var flags : SCNetworkReachabilityFlags = 0
	if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
		return false
	}
	
	let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
	let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
	return (isReachable && !needsConnection)
}

func safeLogout()
{
	PFUser.logOut()
	let fileManager = NSFileManager()
	fileManager.removeItemAtPath(profilePictureLocation, error: nil)
	PFInstallation.currentInstallation().removeObjectForKey("user")
	PFInstallation.currentInstallation().saveEventually(nil)
}

func facebookProfilePicture(#facebookId: String, #size: String, #block: (NSURLResponse!, NSData!, NSError!) -> Void)
{
	let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(facebookId)/picture?type=\(size)&return_ssl_resources=1")!
	let request = NSURLRequest(URL: profilePictureURL)
	NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: block)
}
