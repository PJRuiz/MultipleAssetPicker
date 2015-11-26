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
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView!.allowsMultipleSelection = true
  }

  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    
    // Calculate Thumbnail Size
    let scale = UIScreen.mainScreen().scale
    let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    assetThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    
    collectionView!.reloadData()
    updateSelectedItems()
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
  }
  
  // MARK: UICollectionViewDelegate
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)  {
    // Update selected Assets
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)  {
    // Update selected Assets
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
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AssetCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! AssetCell
    
    // Populate Cell
    
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
}
