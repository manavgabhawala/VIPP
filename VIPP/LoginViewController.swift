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
		
	}/*
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		let blur = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
		blur.frame = useEmail.frame
		blur.frame.size.width = useEmail.frame.size.width + 20
		blur.center.x -= 10
		blur.layer.cornerRadius = 15.0
		blur.clipsToBounds = true
		background.addSubview(blur)
		let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark)))
		vibrancyView.frame.size = useEmail.frame.size
		vibrancyView.frame.origin = CGPointZero
		//vibrancyView.frame.size = blur.frame.size
		//useEmail.center = blur.center
		let someLabel = UILabel()
		someLabel.text = "Some Email"
		//useEmail.center = vibrancyView.contentView.center
		vibrancyView.contentView.addSubview(someLabel)
		blur.contentView.addSubview(vibrancyView)
		
		//background.bringSubviewToFront(useEmail)
		/*let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark)))
		vibrancyView.frame.size = blur.frame.size
		useEmail.removeFromSuperview()
		let useEmailButton = UIButton(frame: CGRect(origin: CGPointZero, size: blur.frame.size))
		useEmailButton.setTitle("Use Email", forState: .Normal)
		useEmailButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		//useEmail.frame.origin = CGPointZero
		vibrancyView.contentView.addSubview(useEmailButton)
		blur.contentView.addSubview(vibrancyView)*/
	}*/
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
						user.saveInBackgroundWithBlock(nil)
					}
				})
			}
		})
	}
	@IBAction func emailLogin(sender: UIButton)
	{
		
	}
}
