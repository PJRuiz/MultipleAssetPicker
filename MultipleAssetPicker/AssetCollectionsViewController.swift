//
//  Created by Pedro Ruíz on 11/26/15.
//
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//


import UIKit
import Photos

protocol AssetPickerDelegate {
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])
  func assetPickerDidCancel()
}

class AssetCollectionsViewController: UITableViewController {
  let AssetCollectionCellReuseIdentifier = "AssetCollectionCell"
  
  // MARK: Variables
  var delegate: AssetPickerDelegate?
  var selectedAssets: SelectedAssets?
  
  private let sectionNames = ["","","Albums"]
  private var userAlbums: PHFetchResult!
  private var userFavorites: PHFetchResult!
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if selectedAssets == nil {
      selectedAssets = SelectedAssets()
    }
    
    // Check for permissions and load assets
    PHPhotoLibrary.requestAuthorization { status in dispatch_async(dispatch_get_main_queue()) {
      switch status { case .Authorized:
      // 2
      self.fetchCollections()
    self.tableView.reloadData() default:
      // 3
      self.showNoAccessAlertAndCancel() }
      } }
  }
  
  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    let destination = segue.destinationViewController
      as! AssetsViewController
    // Set up AssetCollectionViewController
  }
  
  // MARK: Private
  func fetchCollections() {

  }
  
  func showNoAccessAlertAndCancel() {
    let alert = UIAlertController(title: "No Photo Permissions", message: "Please grant Stitch photo access in Settings -> Privacy", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
      self.cancelPressed(self)
    }))
    alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
      UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
      return
    }))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: Actions
  @IBAction func donePressed(sender: AnyObject) {
    delegate?.assetPickerDidFinishPickingAssets(selectedAssets!.assets)
  }
  
  @IBAction func cancelPressed(sender: AnyObject) {
    delegate?.assetPickerDidCancel()
  }
  
  // MARK: UITableViewDataSource
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionNames.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch(section) {
    case 0: // Selected Section
      return 1
    case 1: // All Photos + Favorites
      return 1
    case 2: // Albums
      return 0
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(AssetCollectionCellReuseIdentifier, forIndexPath: indexPath) 
    cell.detailTextLabel!.text = ""
    
    // Populate the table cell
    
    return cell
  }
}
