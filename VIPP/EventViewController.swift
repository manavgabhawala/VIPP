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
	@IBOutlet var collectionView : UICollectionView!
	@IBOutlet var clubName: UILabel!
	@IBOutlet var eventDate: UILabel!
	var fbFriends = [(id: String(), name: String())]
	
	var currentImages = [ImageViewController]()
	var club : Club!
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	
	var pageIndex : Int = 0
	{
		didSet
		{
			if (pageIndex >= club.events.count)
			{
				pageIndex = 0
			}
			if (pageIndex < 0)
			{
				pageIndex = club.events.count - 1
			}
		}
	}
	//MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		clubName.text = club.name
		club.events.sort { $0.date < $1.date }
		getImagesFromServer()
		setDate(0)
		pagingController.delegate = self
		pagingController.dataSource = self
		pagingController.setViewControllers([viewControllerForIndex(0)], direction: .Forward, animated: true, completion: nil)
		pageIndex = 0
		pagingViewContainer.addSubview(pagingController.view)
		if PFUser.currentUser()["fbId"] != nil
		{
			let request = FBRequest.requestForMyFriends()
			request.startWithCompletionHandler {(connection, results, error) in
				if (error == nil)
				{
					let friends = ((results as! NSDictionary).objectForKey("data") as! [NSDictionary]).map { ($0.valueForKey("id") as! String, $0.valueForKey("name") as! String) }
					self.fbFriends = friends.map { (id: $0.0, name: $0.1) }
				}
				else
				{
					//TODO: Show error
					println(error)
				}
			}
		}
	}
	override func viewDidLayoutSubviews()
	{
		let percentage : CGFloat = 0.85
		if (percentage * view.frame.size.width < pagingViewContainer.frame.size.height)
		{
			let centerY = pagingViewContainer.frame.origin.y + pagingViewContainer.frame.size.height / 2
			pagingViewContainer.frame.size = CGSize(width: view.frame.size.width * percentage, height: view.frame.size.width * percentage)
			pagingViewContainer.center.x = view.frame.width / 2
			pagingViewContainer.center.y = centerY
		}
		let frame = pagingViewContainer.frame
		pagingController.view.frame.size = pagingViewContainer.frame.size
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		getFriends()
	}
	//MARK: - Server Interaction
	func getImagesFromServer()
	{
		var index = 0
		if club.events.count > 0
		{
			currentImages = club.events.map {
				let imageViewController = self.viewControllerWithImage($0.image, tag: index)
				$0.delegate = imageViewController
				$0.loadImage()
				++index
				return imageViewController
			}
		}
		else
		{
			let controller = viewControllerWithImage(UIImage(named: "No-Event"), tag: 0)
			currentImages = [controller]
			pagingController.view.userInteractionEnabled = false
		}
		
	}
	func getFriends()
	{
		if (club.events.count > 0 && pageIndex >= 0 && pageIndex < club.events.count)
		{
			club.events[pageIndex].getFriendInfo({
				self.collectionView.reloadSections(NSIndexSet(index: 0))
			})
		}
	}
	
	//MARK: - Actions
	@IBAction func requestBlackCar(_ : UIButton)
	{
		if (pageIndex < club.events.count)
		{
			let requestController = storyboard!.instantiateViewControllerWithIdentifier("RequestCarViewController") as! RequestCarViewController
			requestController.event = club.events[pageIndex]
			requestController.modalPresentationStyle = .FullScreen
			requestController.modalTransitionStyle = .CoverVertical
			presentViewController(requestController, animated: true, completion: nil)
		}
//		let uberClient = "DJIZIgHZ1AwWkLERkkNns0t_7QCW_L7"
//		if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "uber://")!))
//		{
//			// Do something awesome - the app is installed! Launch App.
//			let URL = NSURL(string: "uber://?client_id=\(uberClient)&action=setPickup&pickup=my_location&dropoff[latitude]=\(club.location.latitude)&dropoff[longitude]=\(club.location.longitude)&dropoff[nickname]=\(club.name)&product_id=327f7914-cd12-4f77-9e0c-b27bac580d03")!
//			UIApplication.sharedApplication().openURL(URL)
//		}
//		else
//		{
//			// No Uber app! Open Mobile Website.
//			let URL = NSURL(string: "https://m.uber.com/sign-up?client_id=\(uberClient)&pickup=my_location&dropoff[latitude]=\(club.location.latitude)&dropoff[longitude]=\(club.location.longitude)&dropoff[nickname]=\(club.name)&product_id=327f7914-cd12-4f77-9e0c-b27bac580d03")!
//			UIApplication.sharedApplication().openURL(URL)
//		}
	}
	@IBAction func dismissSelf(_ : UIButton)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func generalShareButtonPressed(_ : UIButton)
	{
		if club.events.count > 0
		{
			let invitationController = storyboard!.instantiateViewControllerWithIdentifier("InvitationsViewController") as! InvitationsViewController
			let invitedFriends = club.events[pageIndex].friends.filter { $0.0 }.map { $0.1 }
			invitationController.facebookFriends = fbFriends.filter { !contains(invitedFriends, $0.id) }
			invitationController.event = club.events[pageIndex]
			invitationController.modalPresentationStyle = .PageSheet
			invitationController.modalTransitionStyle = .CoverVertical
			presentViewController(invitationController, animated: true, completion: nil)
		}
	}
	@IBAction func nextPage(_: UIButton)
	{
		if !(pageIndex + 1 >= club.events.count)
		{
			++pageIndex
			pagingController.setViewControllers([viewControllerForIndex(pageIndex)], direction: .Forward, animated: true, completion: nil)
			setDate(pageIndex)
		}
	}
	@IBAction func previousPage(_: UIButton)
	{
		if !(pageIndex - 1 < 0)
		{
			--pageIndex
			pagingController.setViewControllers([viewControllerForIndex(pageIndex)], direction: .Reverse, animated: false, completion: nil)
			setDate(pageIndex)
		}
	}
}
//MARK: - PageView Stuff
extension EventViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	func viewControllerForIndex(index: Int) -> ImageViewController
	{
		if (index < 0)
		{
			return viewControllerForIndex(currentImages.count - 1)
		}
		if (index >= currentImages.count)
		{
			return viewControllerForIndex(0)
		}
		let controller = currentImages[index]
		controller.imageView.frame.size = pagingViewContainer.frame.size
		return controller
	}
	func viewControllerWithImage(image: UIImage?, tag: Int) -> ImageViewController
	{
		let viewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
		viewController.view.tag = tag
		viewController.disableAnimations = true
		viewController.imageView.image = image
		viewController.imageView.frame.size = pagingViewContainer.frame.size
		return viewController
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
	{
		let index = viewController.view.tag - 1
		if (index < 0)
		{
			return nil
		}
		return viewControllerForIndex(index)
	}
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
	{
		let index = viewController.view.tag + 1
		if (index >= club.events.count)
		{
			return nil
		}
		return viewControllerForIndex(index)
	}
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool)
	{
		if (completed)
		{
			pageIndex = (pageViewController.viewControllers!.first! as! UIViewController).view.tag
			setDate(pageIndex)
			collectionView.reloadSections(NSIndexSet(index: 0))
		}
	}
	func setDate(currentIndex: Int)
	{
		if club.events.count == 0
		{
			eventDate.text = "No Events"
			return
		}
		if (currentIndex >= club.events.count)
		{
			return setDate(0)
		}
		if (currentIndex < 0)
		{
			return setDate(club.events.count - 1)
		}
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		eventDate.text = dateFormatter.stringFromDate(club.events[currentIndex].date)
	}
}
//MARK: - Collection View Stuff
extension EventViewController : UICollectionViewDataSource, UICollectionViewDelegate
{
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		if club.events.count > 0
		{
			return club.events[pageIndex].friends.count
		}
		return 0
	}
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		
		if (club.events[pageIndex].friends[indexPath.row].0)
		{
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCollectionViewCell
			cell.setImage(club.events[pageIndex].friends[indexPath.row].1)
			return cell
		}
		else
		{
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoFBFriendCell", forIndexPath: indexPath) as! FriendWithoutFBCollectionViewCell
			cell.setup(club.events[pageIndex].friends[indexPath.row].1.getInitials())
			return cell
		}
	}
}