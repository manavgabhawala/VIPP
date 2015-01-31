//
//  ViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 1/29/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet var background : UIImageView!
	@IBOutlet var useEmail : UIButton!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		if (PFUser.currentUser() != nil)
		{
			let installation = PFInstallation.currentInstallation()
			if installation["user"] == nil
			{
				installation["user"] = PFUser.currentUser()
				installation.saveInBackgroundWithBlock(nil)
			}
			println("User is logged in")
		}
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	@IBAction func facebookLogin(sender: UIButton)
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
					}
				})
			}
		})
	}
	@IBAction func emailLogin(sender: UIButton)
	{
		
	}
}
