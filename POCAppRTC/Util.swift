//
//  Util.swift
//  POCAppRTC
//
//  Created by Ashish Rathore on 19/03/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation

class Util {
    static func randomNumber() -> Int {
        return Int(arc4random_uniform(1_000_000_000))
    }
}

