//
//  PaneBehavior.swift
//  SlidingTabBar
//
//  Created by Mike on 6/19/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

import UIKit

class PaneBehavior: UIDynamicBehavior {
    
    var targetPoint: CGPoint! {
        didSet {
            if let attachmentBehavior = attachmentBehavior {
                attachmentBehavior.anchorPoint = targetPoint
            }
        }
    }
    var velocity: CGPoint! {
        didSet {
            let currentVelocity = self.itemBehavior.linearVelocityForItem(self.item)
            let velocityDelta = CGPoint(x: velocity.x - currentVelocity.x, y: velocity.y - currentVelocity.y)
            self.itemBehavior.addLinearVelocity(velocityDelta, forItem: self.item)
        }
    }
    
    private var item: UIDynamicItem!
    
    private var itemBehavior: UIDynamicItemBehavior!
    private var attachmentBehavior: UIAttachmentBehavior?
    
    init(item: UIDynamicItem) {
        self.item = item
        super.init()
        setUp()
    }
    
    func setUp() {
        attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: CGPoint.zeroPoint)
        attachmentBehavior!.frequency = 3.5
        attachmentBehavior!.damping = 0.4
        attachmentBehavior!.length = 0
        
        addChildBehavior(attachmentBehavior!)
        
        itemBehavior = UIDynamicItemBehavior(items: [item])
        itemBehavior.density = 100
        itemBehavior.resistance = 10
        addChildBehavior(itemBehavior)
        
    }

}
