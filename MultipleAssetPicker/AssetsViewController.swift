//
//  Created by Pedro Ruíz on 11/26/15.
//
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import UIKit
import Photos

class AssetsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  let AssetCollectionViewCellReuseIdentifier = "AssetCell"
  
  var assetsFetchResults: PHFetchResult?
  var selectedAssets: SelectedAssets!
  
  private var assetThumbnailSize = CGSizeZero
	
	private let imageManager: PHCachingImageManager = PHCachingImageManager()
	private var cachingIndexes: [NSIndexPath] = []
	private var lastCacheFrameCenter: CGFloat = 0
	private var cacheQueue = dispatch_queue_create("cache_queue", DISPATCH_QUEUE_SERIAL)
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView!.allowsMultipleSelection = true
		resetCache()
  }

  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    
    // Calculate Thumbnail Size
    let scale = UIScreen.mainScreen().scale
    let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    assetThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    
    collectionView!.reloadData()
    updateSelectedItems()
		resetCache()
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    collectionView!.reloadData()
    updateSelectedItems()
  }
  
  // MARK: Private
  func currentAssetAtIndex(index:NSInteger) -> PHAsset {
    if let fetchResult = assetsFetchResults {
      return fetchResult[index] as! PHAsset
    } else {
      return selectedAssets.assets[index]
    }
  }
  
  func updateSelectedItems() {
    // Select the selected items
		if let fetchResult = assetsFetchResults {
			for asset in selectedAssets.assets {
				let index = fetchResult.indexOfObject(asset)
				if index != NSNotFound {
					let indexPath = NSIndexPath(forItem: index, inSection: 0)
					collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
				}
			}
		} else {
			for i in 0..<selectedAssets.assets.count {
				let indexPath = NSIndexPath(forItem: i, inSection: 0)
				collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
			}
		}
  }
  
  // MARK: UICollectionViewDelegate
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)  {
    // Update selected Assets
		let asset = currentAssetAtIndex(indexPath.item)
		selectedAssets.assets.append(asset)
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)  {
    // Update selected Assets
		let assetToDelete = currentAssetAtIndex(indexPath.item)
		selectedAssets.assets = selectedAssets.assets.filter { asset in !(asset == assetToDelete)}
		if assetsFetchResults == nil {
			collectionView.deleteItemsAtIndexPaths([indexPath])
		}
  }
  
  
  // MARK: UICollectionViewDataSource
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let fetchResult = assetsFetchResults {
      return fetchResult.count
    } else if selectedAssets != nil {
      return selectedAssets.assets.count
    }
    return 0
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		// 1
	
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AssetCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! AssetCell
    
    // Populate Cell
		let reuseCount = ++cell.reuseCount
		let asset = currentAssetAtIndex(indexPath.item)
		//2
		let options = PHImageRequestOptions()
		options.networkAccessAllowed = true
		// 3
		imageManager.requestImageForAsset(asset, targetSize: assetThumbnailSize, contentMode: .AspectFill, options: options) { result, info in
			if reuseCount == cell.reuseCount {
				cell.imageView.image = result
			}
			
		}
    
    return cell
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var thumbsPerRow: Int
    switch collectionView.bounds.size.width {
    case 0..<400:
      thumbsPerRow = 4
    case 400..<600:
      thumbsPerRow = 5
    case 600..<800:
      thumbsPerRow = 6
    case 800..<1200:
      thumbsPerRow = 7
    default:
      thumbsPerRow = 4
    }
    let width = collectionView.bounds.size.width / CGFloat(thumbsPerRow)
    return CGSize(width: width,height: width)
  }
	
	//MARK: Caching
	func resetCache() {
		imageManager.stopCachingImagesForAllAssets()
		cachingIndexes.removeAll(keepCapacity: true)
		lastCacheFrameCenter = 0
	}
	
	func updateCache() {
		let currentFrameCenter = CGRectGetMidY(collectionView!.bounds)
		if abs(currentFrameCenter - lastCacheFrameCenter) < CGRectGetHeight(collectionView!.bounds) / 3 {
			return
		}
		lastCacheFrameCenter = currentFrameCenter
		let numOffscreenAssetsToCache = 60
		
		var visibleIndexes = collectionView!.indexPathsForVisibleItems() as! [NSIndexPath]
		visibleIndexes.sort { a,b in a.item < b.item }
		
		var totalItemCount = selectedAssets.assets.count
		if let fetchResults = assetsFetchResults {
			totalItemCount = fetchResults.count
		}
		let lastItemToCache = min(totalItemCount, visibleIndexes[visibleIndexes.count - 1].item + numOffscreenAssetsToCache/2)
		let firstItemToCache = max(0, visibleIndexes[0].item - numOffscreenAssetsToCache/2)
		
		let options = PHImageRequestOptions()
		options.networkAccessAllowed = true
		
		var indexesToStopCaching: [NSIndexPath] = []
		cachingIndexes = cachingIndexes.filter { index in
			if index.item < firstItemToCache || index.item > lastItemToCache {
					indexesToStopCaching.append(index)
					return false
			}
			return true
		}
		
		imageManager.stopCachingImagesForAssets(assetsAtIndexPaths(indexesToStopCaching), targetSize: assetThumbnailSize, contentMode: .AspectFill, options: options)
		
		var indexesToStartCaching: [NSIndexPath] = []
		for i in firstItemToCache..<lastItemToCache {
			let indexPath = NSIndexPath(forItem: i, inSection: 0)
			
			if !cachingIndexes.contains(indexPath) {
				indexesToStartCaching.append(indexPath)
			}
			
		}
		cachingIndexes += indexesToStartCaching
		imageManager.startCachingImagesForAssets(assetsAtIndexPaths(indexesToStartCaching), targetSize: assetThumbnailSize, contentMode: .AspectFill, options: options)
		
		
	}
	
	func assetsAtIndexPaths(indexPaths:[NSIndexPath]) -> [PHAsset] {
		return indexPaths.map {
			indexPath in
			return self.currentAssetAtIndex(indexPath.item)
		}
	}
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		dispatch_async(cacheQueue) {
				self.updateCache()
		}
	}
	
	// Final Closure
}

