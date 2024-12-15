//
//  PersistenceService.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation

protocol PersistenceService {
    func latestObject() -> WeatherObject?
    func storeWeather(_ weather: WeatherObject) -> Bool
    func removeLatestObject()
}

struct PersistenceServiceBase: PersistenceService {
    private let userDefaults: UserDefaults
    private let latestKey: String = "com.weatherapp.test.latestKey"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func latestObject() -> WeatherObject? {
        if let weatherData = userDefaults.data(forKey: latestKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(WeatherObject.self, from: weatherData)
        }
        return nil
    }
    
    func storeWeather(_ weather: WeatherObject) -> Bool {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weather) {
            userDefaults.set(encoded, forKey: latestKey)
            return true
        }
        return false
    }
    
    func removeLatestObject() {
        userDefaults.removeObject(forKey: latestKey)
    }
}
