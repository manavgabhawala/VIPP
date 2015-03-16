//
//  ViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 1/29/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
	
	@IBOutlet var backgroundView : UIImageView!
	var currentImageIndex = 0
	let numberOfImages = 3
	var timer : NSTimer!
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		UIApplication.sharedApplication().statusBarStyle = .LightContent
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		if backgroundView.image  == nil
		{
			backgroundView.image = UIImage(named: "Background \(currentImageIndex)")
		}
		timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
		if let user = PFUser.currentUser()
		{
			let installation = PFInstallation.currentInstallation()
			if installation["user"] == nil
			{
				installation["user"] = user
				installation.saveEventually(nil)
			}
			let validVIPP = user["validVIPP"] as? Bool
			if validVIPP != nil && validVIPP!
			{
				let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
				homeViewController.modalPresentationStyle = .FullScreen
				homeViewController.modalTransitionStyle = .CrossDissolve
				self.presentViewController(homeViewController, animated: true, completion: nil)
			}
			else
			{
				if (user["whenGrowsUp"] != nil)
				{
					let finalPage = storyboard!.instantiateViewControllerWithIdentifier("FinalPage") as! ThankYouViewController
					finalPage.modalPresentationStyle = .FullScreen
					finalPage.modalTransitionStyle = .FlipHorizontal
					presentViewController(finalPage, animated: true, completion: nil)
				}
				else
				{
					let signUp = storyboard!.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
					signUp.modalPresentationStyle = .FullScreen
					signUp.modalTransitionStyle = .FlipHorizontal
					presentViewController(signUp, animated: true, completion: nil)
				}
			}
		}
	}
	override func viewDidDisappear(animated: Bool)
	{
		super.viewDidDisappear(animated)
		timer.invalidate()
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: - Actions
	/**
	This funcion is called if the facebook login button is pressed.
	
	:param: _ The UIButton that represents Facebook Login. Anonymous variable because it is unused.
	*/
	@IBAction func facebookLogin(_: UIButton)
	{
		// When your user logs in, immediately get and store its Facebook ID
		PFFacebookUtils.logInWithPermissions(["public_profile", "email", "user_birthday", "user_friends"], block: {(user, error) in
			if (user != nil && error == nil)
			{
				FBRequestConnection.startForMeWithCompletionHandler({(connection, result, error) in
					if (error == nil)
					{
						user["fbId"] = result.objectForKey("id")
						if let firstName = result.objectForKey("first_name") as? String
						{
							user["firstName"] = firstName
						}
						if let lastName = result.objectForKey("last_name") as? String
						{
							user["lastName"] = lastName
						}
						if let email = result.objectForKey("email") as? String
						{
							user["email"] = email
						}
						if let gender = result.objectForKey("gender") as? String
						{
							user["isFemale"] = false
							if gender == "female"
							{
								user["isFemale"] = true
							}
						}
						if let birthday = result.objectForKey("birthday") as? String
						{
							let dateFormatter = NSDateFormatter()
							dateFormatter.dateFormat = "MM/DD/YYYY"
							if let date = dateFormatter.dateFromString(birthday)
							{
								user["birthday"] = date
							}
						}
						let currentInstallation = PFInstallation.currentInstallation()
						currentInstallation["user"] = user
						user.saveInBackgroundWithBlock(nil)
						currentInstallation.saveInBackgroundWithBlock(nil)
						self.performSegueWithIdentifier("signUpDisplay", sender: self)
					}
				})
			}
		})
	}
	func timerFired(_ : NSTimer)
	{
		var newIndex = currentImageIndex
		while (newIndex == currentImageIndex)
		{
			newIndex = Int(arc4random_uniform(UInt32(numberOfImages)))
		}
		currentImageIndex = newIndex
		
		UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
			self.backgroundView.alpha = 0.0
			}, completion: { (completed) in
				self.backgroundView.image = UIImage(named: "Background \(newIndex)")
				UIView.animateWithDuration(1.75, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
					self.backgroundView.alpha = 1.0
					self.view.sendSubviewToBack(self.backgroundView)
					}, completion: nil)
			})
	}
}
