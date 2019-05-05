//
//  Rates.swift
//  Carousel
//
//  Created by Бублик Каширин on 02/05/2019.
//

import Foundation

struct Rates : Decodable {
    let base:String
    var rates: [String: Double]
}
