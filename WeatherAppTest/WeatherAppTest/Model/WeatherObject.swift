//
//  WeatherObject.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation

struct WeatherObject: Codable, Equatable {
        
    let locationName: String
    let teperatureCelsius: Double
    let feelsLikeCelsius: Double
    let humidity: Double
    let uv: Double
    let icon: String?
    let id = UUID()
    
    var iconURL: URL? {
        if let substring = icon?.replacingOccurrences(of: "//", with: "") {
            return URL(string: String("http://" + substring))
        }
        return nil
    }
    
    init (locationName: String, temperatureCelsius: Double, feelsLikeCelsius: Double, humidity: Double, uv: Double, icon: String?) {
        self.locationName = locationName
        self.teperatureCelsius = temperatureCelsius
        self.feelsLikeCelsius = feelsLikeCelsius
        self.humidity = humidity
        self.uv = uv
        self.icon = icon
    }

    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let locationContainer = try container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .location)
        self.locationName = try locationContainer.decode(String.self, forKey: .name)

        let currentContainer = try container.nestedContainer(keyedBy: CodingKeys.CurrentKeys.self, forKey: .current)
        self.teperatureCelsius = try currentContainer.decode(Double.self, forKey: .teperatureCelsius)
        self.feelsLikeCelsius = try currentContainer.decode(Double.self, forKey: .feelsLikeCelsius)
        self.humidity = try currentContainer.decode(Double.self, forKey: .humidity)
        self.uv = try currentContainer.decode(Double.self, forKey: .uv)
        
        let conditionContainer = try currentContainer.nestedContainer(keyedBy: CodingKeys.CurrentKeys.ConditionKeys.self, forKey: .condition)
        self.icon = try? conditionContainer.decode(String.self, forKey: .icon)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var locationContainer = container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .location)
        try locationContainer.encode(locationName, forKey: .name)
        
        var currentContainer = container.nestedContainer(keyedBy: CodingKeys.CurrentKeys.self, forKey: .current)
        try currentContainer.encode(teperatureCelsius, forKey: .teperatureCelsius)
        try currentContainer.encode(feelsLikeCelsius, forKey: .feelsLikeCelsius)
        try currentContainer.encode(humidity, forKey: .humidity)
        try currentContainer.encode(uv, forKey: .uv)

        var conditionContainer = currentContainer.nestedContainer(keyedBy: CodingKeys.CurrentKeys.ConditionKeys.self, forKey: .condition)
        try? conditionContainer.encode(icon, forKey: .icon)
    }
}

private extension WeatherObject {
    enum CodingKeys: String, CodingKey {
        case location, current
        
        enum LocationKeys: String, CodingKey {
            case name
        }

        enum CurrentKeys: String, CodingKey {
            case teperatureCelsius = "temp_c"
            case feelsLikeCelsius = "feelslike_c"
            case humidity
            case uv
            case condition
            
            enum ConditionKeys: String, CodingKey {
                case icon
            }
        }

    }
}

extension WeatherObject {
    static func sampleObject() -> Self {
        .init(
            locationName: "London",
            temperatureCelsius: 28.0,
            feelsLikeCelsius: 29.0,
            humidity: 80.0,
            uv: 10.0,
            icon: "//cdn.weatherapi.com/weather/64x64/day/338.png"
        )
    }
}
