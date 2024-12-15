//
//  Environment.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation

enum Environment: String {
    case WeatherURL, WeatherAPIKey
    
    var value: String {
        if let value = Bundle.main.object(forInfoDictionaryKey: rawValue) as? String {
            return value
        } else {
            fatalError("Key \(rawValue) not found.")
        }
    }
}
