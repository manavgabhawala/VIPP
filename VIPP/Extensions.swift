//
//  Extensions.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/1/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation
import UIKit

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
			if ((self as UITextField).secureTextEntry)
			{
				(self as UITextField).text = ""
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
			if countElements(self) > i
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
		if (countElements(self) <= 10)
		{
			if (countElements(self) > 6)
			{
				self = self.stringByReplacingCharactersInRange(Range<String.Index>(start: self.indexAt(6), end: self.indexAt(6)), withString: "-")
			}
			if (countElements(self) > 3)
			{
				self = self.stringByReplacingCharactersInRange(Range<String.Index>(start: self.indexAt(3), end: self.indexAt(3)), withString: ") ")
			}
			if (countElements(self) > 0)
			{
				self = self.stringByReplacingCharactersInRange(Range<String.Index>(start: self.indexAt(0), end: self.indexAt(0)), withString: "(")
			}
		}
		else
		{
			var remainder = (self as NSString).substringFromIndex(countElements(self) - 10)
			remainder.makeMaskedPhoneText()
			self = "+" + ((self as NSString).substringToIndex(countElements(self) - 10) as String) + " " + (remainder)
		}
	}
	func isValidEmail() -> Bool
	{
		return false
	}
}