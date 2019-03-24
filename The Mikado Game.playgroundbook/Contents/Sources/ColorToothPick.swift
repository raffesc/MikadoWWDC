//
//  ColorScore.swift
//  test
//
//  Created by Raffaele on 20/03/2019.
//  Copyright © 2019 Testers. All rights reserved.
//

import UIKit

public struct ColorToothPick {
    
    var image: UIImage
    var score: Int
    var count: Int
    
    public init(image: UIImage, score: Int,count: Int) {
        self.image = image
        self.score = score
        self.count = count
    }
   
    
}

