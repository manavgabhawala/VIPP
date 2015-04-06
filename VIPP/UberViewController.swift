//
//  UberViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/27/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

private let serverToken = "doEh8iW9O5r4o9ORGKPwe54mW5OSl4PORl07JZkc"
private let clientId = "-DJIZIgHZ1AwWkLERkkNns0t_7QCW_L7"
private let clientSecret = "Adu2PzyBRuCgHNg27exSLe2iRLP5QRwkDxnNH4k5"
private let redirectURL = NSURL(string: "https://getvipp.com/uber")!
private let applicationName = "Vipp"

private let uberAPIBaseURL = "https://api.uber.com/v1/"
var accessToken = ""
var refreshToken = ""
var expiration : NSDate = NSDate(timeIntervalSinceNow: 0)

class UberViewController : UIViewController
{
	var event : Event!
	var productId: String!
	var requestId : String?
	
	@IBOutlet var clubName : UILabel!
	@IBOutlet var eventDate : UILabel!
	@IBOutlet var webView : UIWebView!
	
	let loginView = UIWebView()
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		clubName.text = event.club?.name
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		eventDate.text = dateFormatter.stringFromDate(event.date)
		////// BEGIN TESTING ONLY ////////////
		refreshOAuth2Access()
		//return
		////// END TESTING ONLY ////////////
		
		if let dictionary = NSDictionary(contentsOfFile: uberOAuthCredentialsLocation)
		{
			if let accessTok = dictionary.objectForKey("access_token") as? NSData
			{
				let encodedAccessToken = NSString(data: accessTok, encoding: NSUTF8StringEncoding)! as String
				accessToken = NSString(data: NSData(base64EncodedString: encodedAccessToken, options: nil)!, encoding: NSUTF8StringEncoding) as! String
			}
			if let refreshTok = dictionary.objectForKey("refresh_token") as? NSData
			{
				let encodedRefreshToken = NSString(data: refreshTok, encoding: NSUTF8StringEncoding)! as String
				refreshToken = NSString(data: NSData(base64EncodedString: encodedRefreshToken, options: nil)!, encoding: NSUTF8StringEncoding) as! String
			}
			expiration = dictionary.objectForKey("timeout") as? NSDate ?? NSDate(timeIntervalSinceNow: 0)
			if (accessToken.isEmpty || refreshToken.isEmpty)
			{
				noLoginFound()
			}
			else if (expiration <= NSDate(timeIntervalSinceNow: 0))
			{
				refreshOAuth2Access()
			}
			else
			{
				recievedAccessToken()
			}
		}
		else
		{
			noLoginFound()
		}
		
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func noLoginFound()
	{
		loginView.frame = UIScreen.mainScreen().bounds
		loginView.scalesPageToFit = true
		loginView.delegate = self
		view.addSubview(loginView)
		setupOAuth2AccountStore()
		requestOAuth2Access()
	}
	
	//MARK: - Actions
	@IBAction func backButton(_: UIButton)
	{
		cancelRequest()
		dismissViewControllerAnimated(true, completion: nil)
	}
	func recievedAccessToken()
	{
		let startLatitude = 37.7759792
		let startLongitude = -122.41823
		let parameters = ["product_id" : productId, "start_latitude" : startLatitude, "start_longitude" : startLongitude, "end_latitude" : event.club!.location.latitude, "end_longitude" : event.club!.location.longitude]
		let params = "product_id=\(productId)&start_latitude=\(startLatitude)&start_longitude=\(startLongitude)&end_latitude=\(event.club!.location.latitude)&end_longitude=\(event.club!.location.longitude)"
		
		let URL = NSURL(string: "\(uberAPIBaseURL)requests")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: nil)
		var response: NSURLResponse?
		var error: NSError?
		let immutableRequest = request.copy() as! NSURLRequest
		let requestJSON = NSURLConnection.sendSynchronousRequest(immutableRequest, returningResponse: &response, error: &error)
		
		print("\nJSON: ")
		println(NSJSONSerialization.JSONObjectWithData(requestJSON!, options: nil, error: nil))
		if (error == nil)
		{
			var jsonError : NSError?
			let requestDict = NSJSONSerialization.JSONObjectWithData(requestJSON!, options: nil, error: &jsonError) as! NSDictionary
			if jsonError == nil
			{
				if let request = requestDict.objectForKey("request_id") as? String
				{
					self.requestId = request
					println("Successfully created request with request id: \(requestId)")
					requestMap()
				}
			}
			else
			{
				println("Error while parsing returned JSON: \(jsonError)")
			}
		}
		else
		{
			println("Error while creating an über request: \(error)")
		}
	}
	func requestMap()
	{
		if let requestId = requestId
		{
			let URL = NSURL(string: "\(uberAPIBaseURL)requests/\(requestId)/map")!
			let request = NSMutableURLRequest(URL: URL)
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			var response: NSURLResponse?
			var error: NSError?
			let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
			println(response)
			if (error == nil)
			{
				if let mapDict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as? NSDictionary
				{
					println(mapDict)
					if let mapString = mapDict.valueForKey("href") as? String, let mapURL = NSURL(string: mapString)
					{
						webView.loadRequest(NSURLRequest(URL: mapURL))
					}
					else
					{
						println("Failed to find link in map dictionary.")
					}
				}
				else
				{
					println("Failed to parse returned JSON for map.")
				}
			}
			else
			{
				println(error)
			}
		}
	}
	func cancelRequest()
	{
		if let requestId = requestId
		{
			var response: NSURLResponse?
			var error: NSError?
			let request = NSMutableURLRequest(URL: NSURL(string: "\(uberAPIBaseURL)requests/\(requestId)")!)
			request.HTTPMethod = "DELETE"
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			let requestJSON = NSURLConnection.sendSynchronousRequest(request.copy() as! NSURLRequest, returningResponse: &response, error: &error)
			if (error == nil)
			{
				self.requestId = nil
				println("Successfully cancelled request.")
			}
			else
			{
				println(error)
			}
		}
		else
		{
			println("No request to cancel")
		}
	}
}
//MARK: - WebView Delegate and Login Stuff
extension UberViewController : UIWebViewDelegate
{
	func setupOAuth2AccountStore()
	{
		NXOAuth2AccountStore.sharedStore().setClientID(clientId, secret: clientSecret, authorizationURL: NSURL(string: "https://login.uber.com/oauth/authorize")!, tokenURL: NSURL(string: "https://login.uber.com/oauth/token")!, redirectURL: redirectURL, forAccountType: applicationName)
		
		NSNotificationCenter.defaultCenter().addObserverForName(NXOAuth2AccountStoreAccountsDidChangeNotification, object: NXOAuth2AccountStore.sharedStore(), queue: nil, usingBlock: {(notification) in
			if ((notification.userInfo) != nil)
			{
				println("Success! Recieved access token")
			}
			else
			{
				println("Account removed, lost access")
			}
		})
		
		NSNotificationCenter.defaultCenter().addObserverForName(NXOAuth2AccountStoreDidFailToRequestAccessNotification, object: NXOAuth2AccountStore.sharedStore(), queue: nil, usingBlock: {(notification) in
			if let error = notification.userInfo?[NXOAuth2AccountStoreErrorKey] as? NSError
			{
				println("Error! \(error.localizedDescription)")
			}
		})
	}
	func requestOAuth2Access()
	{
		NXOAuth2AccountStore.sharedStore().requestAccessToAccountWithType(applicationName, withPreparedAuthorizationURLHandler: {(preparedURL) in
			var URL = "\(preparedURL.absoluteString!)&scope=request%20profile"
			println("Requesting prepared URL: \(URL)")
			self.loginView.loadRequest(NSURLRequest(URL: NSURL(string: URL)!))
			UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		})
	}
	func getAuthTokenForCode(code: String)
	{
		let data = "code=\(code)&client_id=\(clientId)&client_secret=\(clientSecret)&redirect_uri=\(redirectURL.absoluteString!)&grant_type=authorization_code"
		let URL = NSURL(string: "https://login.uber.com/oauth/token")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = "POST"
		request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
		
		let immutableRequest = request.copy() as! NSURLRequest
		var response : NSURLResponse?
		var error : NSError?
		
		let authData = NSURLConnection.sendSynchronousRequest(immutableRequest, returningResponse: &response, error: &error)
		
		if (error == nil)
		{
			parseAuthDataReceived(authData!)
		}
		else
		{
			println("Error in sending request for access token: \(error)")
		}
	}
	func refreshOAuth2Access()
	{
		let data = "client_id=\(clientId)&client_secret=\(clientSecret)&redirect_uri=\(redirectURL.absoluteString!)&grant_type=refresh_token&refresh_token=\(refreshToken)"
		let URL = NSURL(string: "https://login.uber.com/oauth/token")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = "POST"
		request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
		
		let immutableRequest = request.copy() as! NSURLRequest
		var response : NSURLResponse?
		var error : NSError?
		
		let authData = NSURLConnection.sendSynchronousRequest(immutableRequest, returningResponse: &response, error: &error)
		println(response)
		if let dict = NSJSONSerialization.JSONObjectWithData(authData!, options: nil, error: nil) as? NSDictionary
		{
			println(dict)
		}
		if (error == nil)
		{
			parseAuthDataReceived(authData!)
		}
		else
		{
			println("Error in sending request for refresh token: \(error)")
			noLoginFound()
		}
	}
	func parseAuthDataReceived(authData: NSData)
	{
		var jsonError : NSError?
		let authDictionary = NSJSONSerialization.JSONObjectWithData(authData, options: nil, error: &jsonError) as! NSDictionary
		if (jsonError == nil)
		{
			if let access = authDictionary.objectForKey("access_token") as? String
			{
				accessToken = access
				if let refresh = authDictionary.objectForKey("refresh_token") as? String, let timeout = authDictionary.objectForKey("expires_in") as? NSTimeInterval
				{
					let time = NSDate(timeInterval: timeout, sinceDate: NSDate(timeIntervalSinceNow: 0))
					refreshToken = refresh
					let encodedAccessToken = accessToken.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedDataWithOptions(nil)
					let encodedRefreshToken = accessToken.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedDataWithOptions(nil)
					let dictionary : NSDictionary = ["access_token" : encodedAccessToken, "refresh_token" : encodedRefreshToken, "timeout" : time];
					
					if dictionary.writeToFile(uberOAuthCredentialsLocation, atomically: true)
					{
						println("Successfully saved oauth details")
					}
					else
					{
						println("Failed to save oauth details")
					}
				}
				
				println("Got access token: \(accessToken)\n")
				recievedAccessToken()
			}
		}
		else
		{
			println("Error retrieving access token. Recieved JSON Error: \(jsonError)")
		}
	}
	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
	{
		if let URL = request.URL?.absoluteString
		{
			if URL.hasPrefix(redirectURL.absoluteString!)
			{
				var code : String?
				if let URLParams = request.URL?.query?.componentsSeparatedByString("&")
				{
					for param in URLParams
					{
						let keyValue = param.componentsSeparatedByString("=")
						let key = keyValue.first
						if key == "code"
						{
							code = keyValue.last
							println("Code: \(code)\n")
						}
					}
				}
				if let code = code
				{
					getAuthTokenForCode(code)
					loginView.removeFromSuperview()
				}
				else
				{
					println("Error from UIWebView")
				}
				return false
			}
		}
		return true
	}
	func webView(webView: UIWebView, didFailLoadWithError error: NSError)
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		//TODO: Show error
		println(error)
	}
	func webViewDidFinishLoad(webView: UIWebView)
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}
}
