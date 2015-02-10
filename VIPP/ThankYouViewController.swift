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
	@IBAction func facebookShare(_: UIButton)
	{
		let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
		facebookSheet.setInitialText("Some random text here!")
		presentViewController(facebookSheet, animated: true, completion: nil)
	}
	@IBAction func twitterShare(_: UIButton)
	{
		let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
		tweetSheet.setInitialText("Some random text here!")
		presentViewController(tweetSheet, animated: true, completion: nil)
	}
	@IBAction func emailShare(_: UIButton)
	{
		let emailController = MFMailComposeViewController()
		emailController.setMessageBody("Some random text here!", isHTML: false)
		emailController.setSubject("Vipp! The next cool thing is here")
		presentViewController(emailController, animated: true, completion: nil)
	}
	@IBAction func textShare(_: UIButton)
	{
		let messageController = MFMessageComposeViewController()
		messageController.body = "Some random text here!"
		presentViewController(messageController, animated: true, completion: nil)
	}
}