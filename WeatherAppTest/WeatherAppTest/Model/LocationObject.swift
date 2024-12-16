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
    let region: String
    let country: String
}

extension LocationObject {
    static func sampleObject() -> LocationObject {
        .init(id: 2801268, name: "London", region: "City of London, Greater London", country: "United Kingdom")
    }
}
