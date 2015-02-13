//
//  FinalPageViewController.swift
//  VIPP
//
//  Created by Robert Levy on 2/5/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation
import UIKit
import Social
import MessageUI

class ThankYouViewController: UIViewController
{
	let socialText = "Some random text here"
	let subjectText = "Vipp - The Next Cool Thing"
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().statusBarStyle = .Default
	}
	@IBAction func facebookShare(_: UIButton)
	{
		let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
		facebookSheet.setInitialText(socialText)
		presentViewController(facebookSheet, animated: true, completion: nil)
	}
	@IBAction func twitterShare(_: UIButton)
	{
		let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
		tweetSheet.setInitialText(socialText)
		presentViewController(tweetSheet, animated: true, completion: nil)
	}
	@IBAction func emailShare(_: UIButton)
	{
		let emailController = MFMailComposeViewController()
		emailController.setMessageBody(socialText, isHTML: false)
		emailController.mailComposeDelegate = self
		emailController.setSubject(subjectText)
		presentViewController(emailController, animated: true, completion: nil)
	}
	@IBAction func textShare(_: UIButton)
	{
		let messageController = MFMessageComposeViewController()
		messageController.messageComposeDelegate = self
		messageController.body = socialText
		presentViewController(messageController, animated: true, completion: nil)
	}
}
extension ThankYouViewController : MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate
{
	func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult)
	{
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
	{
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}