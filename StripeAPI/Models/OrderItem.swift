//
//  OrderItem.swift
//  StripeAPI
//
//  Created by nori on 2017/10/16.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation

public struct OrderItem: Decodable {

    public let object: String
    public let amount: Int
    public let currency: String
    public let description: String
    public let parent: String
    public let quantity: Int?
    public let type: String
}
