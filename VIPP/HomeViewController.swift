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
	@IBOutlet var requestButton : UIButton!
	let pagingController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	
	var clubs = [Club]()
	var currentImages = [ImageViewController]() //This is for the bottom images.
	
	var currentIndex = 0
	private let preDefinedLimit = 10
	private let numberOfClubsPerPage = 9
	private let numberOfRowsPerPage = 3
	private let numberOfColumnsPerPage = 3
	
	private let numberOfImagesSlideshow = 3
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		assert(numberOfRowsPerPage * numberOfColumnsPerPage == numberOfClubsPerPage, "The number of rows (\(numberOfRowsPerPage)) * the number of columns (\(numberOfColumnsPerPage)) must equal the number of Clubs per page (\(numberOfClubsPerPage))")
		loadNextClubs()
		setCurrentImagesToDefault()
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.pagingEnabled = true
		pagingController.delegate = self
		pagingController.dataSource = self
		pagingController.setViewControllers([currentImages[0]], direction: .Forward, animated: true, completion: nil)
		pagingViewContainer.addSubview(pagingController.view)
		pagingViewContainer.sendSubviewToBack(pagingController.view)
		UIApplication.sharedApplication().statusBarStyle = .Default
	}
	override func viewDidLayoutSubviews()
	{
		pagingController.view.frame.size = pagingViewContainer.frame.size
		pagingControl.numberOfPages = numberOfImagesSlideshow
	}
	
	@IBAction func requestBlackCar(_ : UIButton)
	{
		if let indexPath = collectionView.indexPathsForSelectedItems().first as? NSIndexPath
		{
			if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ClubCollectionViewCell
			{
				let location = cell.club.location
				println("Call uber with drop off location: \(cell.club.location)")
			}
		}
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
		query.findObjectsInBackgroundWithBlock{ (results, error) in
			if (error == nil && results != nil)
			{
				if (results.count == 0) { return }
				if let actualResults = results as? [PFObject]
				{
					actualResults.map { self.clubs.append(Club(name: $0["name"] as String, url: NSURL(string: $0["logo"] as String), location: $0["geoLocation"] as PFGeoPoint, photos: $0["photos"] as [String])) }
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
	func setCurrentImagesToDefault()
	{
		for i in 0..<numberOfImagesSlideshow
		{
			let image = UIImage(named: "Logo")
			if (i < currentImages.count)
			{
				currentImages[i].imageView.image = image
				currentImages[i].imageView.setNeedsDisplay()
			}
			else
			{
				currentImages.append(viewControllerWithImage(image, tag: i))
			}
		}
	}
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
		return currentImages[index]
	}
	func viewControllerWithImage(image: UIImage?, tag: Int) -> ImageViewController
	{
		let viewController = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as ImageViewController
		viewController.view.tag = tag
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
			pagingControl.currentPage = (pageViewController.viewControllers.first! as UIViewController).view.tag
		}
	}
	@IBAction func pageControlValueChange(pageControl: UIPageControl)
	{
		let currentIndex = (pagingController.viewControllers.first as UIViewController).view.tag
		let direction = pageControl.currentPage < currentIndex ? UIPageViewControllerNavigationDirection.Reverse : .Forward
		pagingController.setViewControllers([viewControllerForIndex(pageControl.currentPage)], direction: direction, animated: true, completion: nil)
	}
}
//MARK: - Collection View Stuff
extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return numberOfClubsPerPage
	}
	
	// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let index = (indexPath.section * numberOfClubsPerPage) + indexPath.row
		if  index < clubs.count
		{
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClubCell", forIndexPath: indexPath) as ClubCollectionViewCell
			cell.backgroundView = UIImageView(image: UIImage(named: "CellBackground"))
			cell.backgroundView?.contentMode = .ScaleAspectFill
			cell.selectedBackgroundView = UIImageView(image: UIImage(named: "CellBackgroundSelected"))
			cell.selectedBackgroundView?.contentMode = .ScaleAspectFill
			let club = clubs[index]
			cell.label.text = club.name
			cell.club = club
			club.delegate = cell
			if let image = club.logo
			{
				cell.setImage(image)
			}
			return cell
		}
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DefaultCell", forIndexPath: indexPath) as UICollectionViewCell
		cell.backgroundView = UIImageView(image: UIImage(named: "DefaultCell"))
		cell.backgroundView?.contentMode = .ScaleAspectFill
		return cell
	}
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		//TODO: Implement Me
		return Int(ceil(Double(clubs.count) / Double(numberOfClubsPerPage)))
	}
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		setCurrentImagesToDefault()
		let index = (indexPath.section * numberOfClubsPerPage) + indexPath.row
		if  index < clubs.count
		{
			let club = clubs[index]
			if club.photos.count > 0
			{
				for (i, photo) in enumerate(club.photos)
				{
					currentImages[i].imageView.image = photo
					currentImages[i].imageView.setNeedsDisplay()
				}
			}
			else
			{
				for (i, aPhotoURL) in enumerate(club.photoURLS)
				{
					if (i < numberOfImagesSlideshow)
					{
						if let photoURL = aPhotoURL
						{
							let downloadRequest = NSURLRequest(URL: photoURL, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30.0)
							NSURLConnection.sendAsynchronousRequest(downloadRequest, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
								if let image = UIImage(data: data)
								{
									if (i < club.photos.count)
									{
										club.photos[i] = image
									}
									else
									{
										club.photos.append(image)
									}
									if (i < self.currentImages.count)
									{
										self.currentImages[i].imageView.image = image
										self.currentImages[i].imageView.setNeedsDisplay()
									}
								}
							})
						}
					}
				}
			}
			requestButton.enabled = true
		}
	}
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
	{
		let interCellHorizontalSpacing = (collectionViewLayout as UICollectionViewFlowLayout).minimumInteritemSpacing * CGFloat(numberOfColumnsPerPage)
		let totalWidth = collectionView.frame.width - (collectionViewLayout as UICollectionViewFlowLayout).sectionInset.left - (collectionViewLayout as UICollectionViewFlowLayout).sectionInset.right - interCellHorizontalSpacing
		
		let interCellVerticalSpacing = (collectionViewLayout as UICollectionViewFlowLayout).minimumLineSpacing * CGFloat(numberOfRowsPerPage)
		let totalHeight = collectionView.frame.height - (collectionViewLayout as UICollectionViewFlowLayout).sectionInset.top - (collectionViewLayout as UICollectionViewFlowLayout).sectionInset.bottom - interCellVerticalSpacing
		
		return CGSize(width: totalWidth / CGFloat(numberOfColumnsPerPage), height: totalHeight / CGFloat(numberOfRowsPerPage))
	}
}