//
//  Created by Pedro Ruíz on 11/26/15.
//
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import UIKit
import Photos

class SelectedAssets: NSObject {
  var assets: [PHAsset]
  
  override init() {
    assets = []
  }
  
  init(assets:[PHAsset]) {
    self.assets = assets
  }
  
}
