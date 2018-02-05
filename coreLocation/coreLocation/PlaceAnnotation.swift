//
//  PlaceAnnotation.swift
//  NeAR Me
//
//  Created by Josh Dobson on 2/5/18.
//  Copyright © 2018 Josh Dobson. All rights reserved.
//

import Foundation
import ARCL
import CoreLocation
import SceneKit

class PlaceAnnotation : LocationNode {
    var title :String!
    var annotationNode :SCNNode
    
    init(location: CLLocation?, title: String) {
        self.annotationNode = SCNNode()
        super.init(location: location)
        
        self.title = title
        //2:32
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



