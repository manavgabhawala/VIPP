//
//  AppDelegate.swift
//  VIPP
//
//  Created by Manav Gabhawala on 1/29/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	{
		// Override point for customization after application launch.
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
		Parse.enableLocalDatastore()
		Parse.setApplicationId("OtIEGP5KKeYGnXvjIUKlqT3NSgQA3Sk043bEUCoC", clientKey: "ztvCIMnziOvdzCm2JxZj5hzMRN8TBq1lypC0cn8y")
		let userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound)
		let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
		application.registerUserNotificationSettings(settings)
		application.registerForRemoteNotifications()
		PFFacebookUtils.initializeFacebook()
		if let user = PFUser.currentUser()
		{
			let installation = PFInstallation.currentInstallation()
			if installation["user"] == nil
			{
				installation["user"] = user
				installation.saveEventually(nil)
			}
		}
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
	{
		let currentInstallation = PFInstallation.currentInstallation()
		currentInstallation.setDeviceTokenFromData(deviceToken)
		currentInstallation.channels = ["global"]
		if let user = PFUser.currentUser()
		{
			currentInstallation["user"] = user
		}
		currentInstallation.saveInBackgroundWithBlock(nil)
	}
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
	{
		PFPush.handlePush(userInfo)
	}
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
	{
		// You can add your app-specific url handling code here if needed
		return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
	}
}

