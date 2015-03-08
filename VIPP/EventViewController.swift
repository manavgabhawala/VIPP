//
//  EventViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 3/3/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class EventViewController : UIViewController
{
	@IBOutlet var pagingViewContainer : UIView!
	@IBOutlet var clubName: UILabel!
	@IBOutlet var eventDate: UILabel!
	
	var currentImages = [ImageViewController]()
	var club : Club!
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		clubName.text = club.name
		if club.events.count == 0
		{
			//TODO: No events found
			println("No events found")
		}
		club.events.sort { $0.date < $1.date }
		let firstDate = club.events.first?.date
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		eventDate.text = dateFormatter.stringFromDate(firstDate ?? NSDate(timeIntervalSinceNow: 0))
		getImagesFromServer()
		pagingController.delegate = self
		pagingController.dataSource = self
		pagingController.setViewControllers([viewControllerForIndex(0)], direction: .Forward, animated: true, completion: nil)
		pagingViewContainer.addSubview(pagingController.view)
	}
	override func viewDidLayoutSubviews()
	{
		if (view.frame.size.width < pagingViewContainer.frame.size.height)
		{
			let centerY = pagingViewContainer.frame.origin.y + pagingViewContainer.frame.size.height / 2
			pagingViewContainer.frame.size = CGSize(width: view.frame.size.width, height: view.frame.size.width)
			pagingViewContainer.center.x = view.frame.width / 2
			pagingViewContainer.center.y = centerY
		}
		let percentage : CGFloat = 1.0
		let frame = pagingViewContainer.frame
		pagingController.view.frame = CGRect(origin: CGPoint(x: frame.width * (1 - percentage) / 2, y: 0), size: CGSize(width: frame.width * percentage, height: frame.height))
	}
	
	//MARK: - Server Interaction
	func getImagesFromServer()
	{
		var index = 0
		currentImages = club.events.map {
			let imageViewController = self.viewControllerWithImage($0.image, tag: index)
			$0.controller = imageViewController
			$0.loadImage()
			++index
			return imageViewController
		}
	}
	func getFriends()
	{
		
	}
	
	//MARK: - Actions
	@IBAction func requestBlackCar(_ : UIButton)
	{
		let uberClient = "DJIZIgHZ1AwWkLERkkNns0t_7QCW_L7"
		if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "uber://")!))
		{
			// Do something awesome - the app is installed! Launch App.
			let URL = NSURL(string: "uber://?client_id=\(uberClient)&action=setPickup&pickup=my_location&dropoff[latitude]=\(club.location.latitude)&dropoff[longitude]=\(club.location.longitude)&dropoff[nickname]=\(club.name)&product_id=327f7914-cd12-4f77-9e0c-b27bac580d03")!
			UIApplication.sharedApplication().openURL(URL)
		}
		else
		{
			// No Uber app! Open Mobile Website.
			let URL = NSURL(string: "https://m.uber.com/sign-up?client_id=\(uberClient)&pickup=my_location&dropoff[latitude]=\(club.location.latitude)&dropoff[longitude]=\(club.location.longitude)&dropoff[nickname]=\(club.name)&product_id=327f7914-cd12-4f77-9e0c-b27bac580d03")!
			UIApplication.sharedApplication().openURL(URL)
		}
	}
	@IBAction func dismissSelf(_ : UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func generalShareButtonPressed(_ : UIButton)
	{
		
	}
	@IBAction func friendIconPressed(user: PFUser)
	{
		
	}
}
extension EventViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	func viewControllerForIndex(index: Int) -> ImageViewController
	{
		if (currentImages.count == 0)
		{
			//FIXME: Remove me later
			let controller = storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
			controller.imageView.image = UIImage(named: "placeholder.png")
			return controller
		}
		if (index < 0)
		{
			return viewControllerForIndex(currentImages.count - 1)
		}
		if (index >= currentImages.count)
		{
			return viewControllerForIndex(0)
		}
		return currentImages[index]
	}
	func viewControllerWithImage(image: UIImage?, tag: Int) -> ImageViewController
	{
		let viewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
		viewController.view.tag = tag
		viewController.disableAnimations = true
		viewController.imageView.image = image
		viewController.view.frame.size = pagingViewContainer.frame.size
		return viewController
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
	{
		let index = viewController.view.tag - 1
		return viewControllerForIndex(index)
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
	{
		let index = viewController.view.tag + 1
		return viewControllerForIndex(index)
	}
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool)
	{
		if (completed)
		{
			let currentIndex = (pageViewController.viewControllers.first! as! UIViewController).view.tag
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateStyle = .LongStyle
			eventDate.text = dateFormatter.stringFromDate(club.events[currentIndex].date)
		}
	}
}