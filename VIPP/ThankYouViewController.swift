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
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().statusBarStyle = .Default
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		let user = PFUser.currentUser()
		let validVIPP = user["validVIPP"] as? Bool
		println(validVIPP)
		if validVIPP != nil && validVIPP!
		{
			let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
			homeViewController.modalPresentationStyle = .FullScreen
			homeViewController.modalTransitionStyle = .CrossDissolve
			self.presentViewController(homeViewController, animated: true, completion: nil)
		}
	}
	@IBAction func facebookShare(_: UIButton)
	{
		let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
		facebookSheet.setInitialText("I'll be attending elite nightlife venues with Vipp (facebook.com/getvipp) – sign up here to join me: http://getvipp.com")
		presentViewController(facebookSheet, animated: true, completion: nil)
	}
	@IBAction func twitterShare(_: UIButton)
	{
		let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
		tweetSheet.setInitialText("I'll be attending elite nightlife venues with @getvipp – want to join? http://getvipp.com")
		presentViewController(tweetSheet, animated: true, completion: nil)
	}
	@IBAction func emailShare(_: UIButton)
	{
		let emailController = MFMailComposeViewController()
		emailController.setMessageBody("Download this to get into top nightlife venues with me! http://getvipp.com", isHTML: false)
		emailController.mailComposeDelegate = self
		emailController.setSubject("Check out this Vipp app")
		presentViewController(emailController, animated: true, completion: nil)
	}
	@IBAction func textShare(_: UIButton)
	{
		let messageController = MFMessageComposeViewController()
		messageController.messageComposeDelegate = self
		messageController.body = "Check out this Vipp app – Download this to get into top nightlife venues with me! http://getvipp.com"
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