//
//  LocationObject.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import Foundation

struct LocationObject: Codable, Equatable {
    let id: Int
    let name: String
    let url: String
}

extension LocationObject {
    static func sampleObject() -> LocationObject {
        .init(id: 2801268, name: "London", url: "london-city-of-london-greater-london-united-kingdom")
    }
}
