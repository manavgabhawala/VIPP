//
//  HomeViewController.swift
//  VIPP
//
//  Created by Manav Gabhawala on 2/26/15.
//  Copyright (c) 2015 VIPP. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController
{
	@IBOutlet var collectionView : UICollectionView!
	@IBOutlet var pagingViewContainer : UIView!
	@IBOutlet var pagingControl : UIPageControl!
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	
	var clubs = [Club]()
	var currentImages : [UIImage] = [UIImage]() //This is for the bottom images.
	{
		didSet
		{
			let currentIndex = pagingControl.currentPage
			pagingControl.numberOfPages = currentImages.count
			pagingControl.currentPage = currentIndex
			pagingController.setViewControllers([viewControllerForIndex(currentIndex)], direction: .Forward, animated: false, completion: nil)
		}
	}
	
	var currentIndex = 0
	private let preDefinedLimit = 10
	private let numberOfClubsPerPage = 9
	
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
	}
	
	
}
//MARK: - Parse Interaction
extension HomeViewController
{
	func loadNextClubs()
	{
		let query = PFQuery(className: "Club")
		query.limit = preDefinedLimit
		query.skip = currentIndex
		query.cachePolicy = kPFCachePolicyNetworkElseCache
		query.findObjectsInBackgroundWithBlock{ (results, error) in
			if (error == nil && results != nil)
			{
				if (results.count == 0) { return }
				if let actualResults = results as? [PFObject]
				{
					actualResults.map { self.clubs.append(Club(name: $0["name"] as String, url: NSURL(string: $0["logo"] as String), location: $0["location"] as PFGeoPoint, photos: $0["photos"] as [String])) }
					self.currentIndex += results.count
				}
				self.loadNextClubs()
				self.collectionView.reloadData()
			}
			else
			{
				//TODO: Show error
			}
		}
	}
}

//MARK: - Paging Controller Stuff
extension HomeViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource
{
	func viewControllerForIndex(index: Int) -> UIViewController
	{
		if (index < 0)
		{
			return viewControllerForIndex(currentImages.count - 1)
		}
		if (index >= currentImages.count)
		{
			return viewControllerForIndex(0)
		}
		let viewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as ImageViewController
		viewController.view.tag = index
		viewController.imageView.image = currentImages[index]
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
			pagingControl.currentPage = (pageViewController.viewControllers.first! as UIViewController).view.tag
		}
	}
	@IBAction func pageControlValueChange(pageControl: UIPageControl)
	{
		let currentIndex = (pagingController.viewControllers.first as UIViewController).view.tag
		if (pageControl.currentPage < currentIndex)
		{
			pagingController.setViewControllers([viewControllerForIndex(pageControl.currentPage)], direction: .Reverse, animated: true, completion: nil)
		}
		else
		{
			pagingController.setViewControllers([viewControllerForIndex(pageControl.currentPage)], direction: .Forward, animated: true, completion: nil)
		}
	}
}
//MARK: - Collection View Stuff
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		//TODO: Implement Me
		return numberOfClubsPerPage
	}
	
	// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		//TODO: Implement Me
		let index = (indexPath.section * numberOfClubsPerPage) + indexPath.row
		if  index < clubs.count
		{
			let club = clubs[indexPath.section * indexPath.row]
			//TODO: Set delegate for Club to collection view cell.
		}
		//??? If we reach here it means we have extra cells for this page. Decide what to return here.
		return UICollectionViewCell()
	}
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		//TODO: Implement Me
		return Int(ceil(Double(clubs.count) / Double(numberOfClubsPerPage)))
	}
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		let index = (indexPath.section * numberOfClubsPerPage) + indexPath.row
		if  index < clubs.count
		{
			let club = clubs[indexPath.section * indexPath.row]
			//TODO: Change cell appearance and other complicated stuff.
		}
	}
}