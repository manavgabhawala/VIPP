//
//  ViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 1/29/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
	
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		PFUser.logOut()
	}
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		UIApplication.sharedApplication().statusBarStyle = .LightContent
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)		
		if let user = PFUser.currentUser()
		{
			let installation = PFInstallation.currentInstallation()
			if installation["user"] == nil
			{
				installation["user"] = user
				installation.saveEventually(nil)
			}
			if (user["isValidVIPP"] != nil && user["isValidVIPP"] as Bool)
			{
				//TODO: Give Full Access
			}
			else
			{
				if (user["whenGrowsUp"] != nil)
				{
					let finalPage = storyboard!.instantiateViewControllerWithIdentifier("FinalPage") as ThankYouViewController
					finalPage.modalPresentationStyle = .FullScreen
					finalPage.modalTransitionStyle = .FlipHorizontal
					presentViewController(finalPage, animated: true, completion: nil)
				}
				else
				{
					let signUp = storyboard!.instantiateViewControllerWithIdentifier("SignUpViewController") as SignUpViewController
					signUp.modalPresentationStyle = .FullScreen
					signUp.modalTransitionStyle = .FlipHorizontal
					presentViewController(signUp, animated: true, completion: nil)
				}
			}
		}
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
	
}
