//
//  Created by Pedro Ruíz on 11/26/15.
//
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import UIKit

class AssetCell: UICollectionViewCell {
  
  @IBOutlet var imageView: UIImageView!
  var reuseCount: Int = 0

  @IBOutlet private var checkMark: UIView?
  
  override var selected: Bool {
    didSet {
      checkMark?.hidden = !selected
    }
  }
}
