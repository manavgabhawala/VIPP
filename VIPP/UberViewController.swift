//
//  UberViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/27/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit
private let serverToken = "doEh8iW9O5r4o9ORGKPwe54mW5OSl4PORl07JZkc"

class UberViewController : UIViewController
{
	var event : Event!
	@IBOutlet var clubName : UILabel!
	@IBOutlet var eventDate : UILabel!
	var productId: String!
	
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		clubName.text = event.club?.name
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		eventDate.text = dateFormatter.stringFromDate(event.date)
		let loginURL = NSURL(string: "https://login.uber.com/oauth/authorize")!
		let request = NSMutableURLRequest(URL: loginURL)
		request.HTTPMethod = "GET"
		let token = "Token \(serverToken)"
		request.addValue(token, forHTTPHeaderField: "Authorization")
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
			
		})
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: - Actions
	@IBAction func backButton(_: UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
}
