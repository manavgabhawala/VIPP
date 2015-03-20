//
//  SlideDownSegue.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/13/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class SlideDownSegue: UIStoryboardSegue
{
	override init!(identifier: String?, source: UIViewController, destination: UIViewController)
	{
		super.init(identifier: identifier, source: source, destination: destination)
	}
	override func perform()
	{
		(sourceViewController as! UIViewController).view.addSubview((destinationViewController as! UIViewController).view)
		(sourceViewController as! UIViewController).view.bringSubviewToFront((destinationViewController as! UIViewController).view)
		let originalCenter = (sourceViewController as! UIViewController).view.center
		(destinationViewController as! UIViewController).view.frame.origin.y = -(sourceViewController as! UIViewController).view.frame.height + 64.0
		UIView.animateWithDuration(1.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
				(self.destinationViewController as! UIViewController).view.center = originalCenter
			}, completion: {(completed) in
				if completed
				{
					(self.destinationViewController as! UIViewController).view.userInteractionEnabled = false
					(self.destinationViewController as! UIViewController).view.removeFromSuperview()
					(self.sourceViewController as! UIViewController).presentViewController((self.destinationViewController as! UIViewController), animated: false, completion: {
						(self.destinationViewController as! UIViewController).view.userInteractionEnabled = true
					})
					
				}
		})
		
	}
}

class SlideUpSegue : UIStoryboardSegue
{
	override init!(identifier: String?, source: UIViewController, destination: UIViewController)
	{
		super.init(identifier: identifier, source: source, destination: destination)
	}
	override func perform()
	{
		(sourceViewController as! UIViewController).view.superview?.insertSubview((destinationViewController as! UIViewController).view, atIndex: 0)
		UIApplication.sharedApplication().statusBarStyle = .Default
		UIView.animateWithDuration(1.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
			(self.sourceViewController as! UIViewController).view.frame.origin.y = -(self.destinationViewController as! UIViewController).view.frame.height + 64.0
			}, completion: {(completed) in
				if completed
				{
					(self.destinationViewController as! UIViewController).dismissViewControllerAnimated(false, completion: nil)
				}
		})
	}
}
