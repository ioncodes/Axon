//
//  Method.swift
//  Axon
//
//  Created by Luca Marcelli on 31.03.18.
//  Copyright © 2018 Luca Marcelli. All rights reserved.
//

import Foundation

struct Method: Encodable {
    var name: String
    var type: String
    var returnType: String
    var args: [String]
}
