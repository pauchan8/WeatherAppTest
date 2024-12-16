//
//  PersistenceService.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation

protocol PersistenceService {
    func latestObject() -> AggregatedWeatherObject?
    func storeWeather(_ weather: AggregatedWeatherObject) -> Bool
    func removeLatestObject()
}

struct PersistenceServiceBase: PersistenceService {
    private let userDefaults: UserDefaults
    private let latestKey: String = "com.weatherapp.test.latestKey"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func latestObject() -> AggregatedWeatherObject? {
        if let weatherData = userDefaults.data(forKey: latestKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(AggregatedWeatherObject.self, from: weatherData)
        }
        return nil
    }
    
    func storeWeather(_ weather: AggregatedWeatherObject) -> Bool {
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
