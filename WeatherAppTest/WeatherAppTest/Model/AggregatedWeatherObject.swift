//
//  AggregatedWeatherObject.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import Foundation

struct AggregatedWeatherObject: Codable, Equatable, Identifiable {
    let weatherObject: WeatherObject
    let locationObject: LocationObject
    
    var id: Int { locationObject.id }
    var locationName: String { weatherObject.locationName }
    var teperatureCelsius: Double { weatherObject.teperatureCelsius }
    var feelsLikeCelsius: Double { weatherObject.feelsLikeCelsius }
    var humidity: Double { weatherObject.humidity }
    var uv: Double { weatherObject.uv }
    var icon: String? { weatherObject.icon }
    var iconURL: URL? { weatherObject.iconURL }
}

extension AggregatedWeatherObject {
    static func sampleObject() -> AggregatedWeatherObject {
        .init(
            weatherObject: .sampleObject(),
            locationObject: .sampleObject()
        )
    }
}
