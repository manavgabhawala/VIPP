//
//  TermsAndConditionViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/9/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import Foundation
import UIKit

class TermsAndConditionsViewController : UIViewController
{
	@IBAction func dismissAction(_: UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
}

class ImageViewController : UIViewController
{
	@IBOutlet var imageView : UIImageView!
	var appeared = false
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		if (!appeared)
		{
			let actualFrame = imageView.frame
			imageView.frame.origin.y = view.frame.height / 2
			UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
				options: .CurveEaseInOut, animations:
				{
					self.imageView.frame = actualFrame
				}, completion:
				{ (completed) in self.appeared = true })
		}
	}
	override func viewDidDisappear(animated: Bool)
	{
		appeared = false
	}
}