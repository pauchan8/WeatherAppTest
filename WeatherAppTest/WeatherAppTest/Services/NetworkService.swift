//
//  NetworkService.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData(String)
    case noLocationMatching
    case apiKeyError(String)
    case internalError(String)
    
    init?(weatherError: WeatherError) {
        switch weatherError.code {
        case 1006:
            self = .noLocationMatching
        case 9999:
            self = .internalError("Server issues: " + weatherError.message)
        case 2006...2009:
            self = .apiKeyError("API key error: " + weatherError.message)
        default:
            return nil
        }
    }
}

protocol NetworkService {
    func fetchWeather(location: String) async throws(NetworkError) -> WeatherObject
}

class NetworkServiceBase: NetworkService {

    private let baseUrl: URL
    private let apiKey: String
    private let session: URLSession

    init(baseUrl: URL, apiKey: String, session: URLSession) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        self.session = session
    }
    
    func fetchWeather(location: String) async throws(NetworkError) -> WeatherObject {
        var fetchComponents = URLComponents(url: baseUrl.appending(component: "current.json"), resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: location),
            URLQueryItem(name: "aqi", value: "no")
        ]
        
        guard let fetchURL = fetchComponents?.url else { throw .invalidURL }
        let responseTuple: (Data, URLResponse)
        do {
            responseTuple = try await URLSession.shared.data(from: fetchURL)
        } catch {
            throw .invalidData(error.localizedDescription)
        }
        
        guard let response = responseTuple.1 as? HTTPURLResponse, response.statusCode == 200 else {
            let decodedError = try? JSONDecoder().decode(WeatherError.self, from: responseTuple.0)
            let error = decodedError.flatMap { NetworkError(weatherError: $0) }
            throw error ?? .invalidResponse
        }
        
        do {
            let object = try JSONDecoder().decode(WeatherObject.self, from: responseTuple.0)
            return object
        } catch {
            throw .invalidData(error.localizedDescription)
        }
    }
}

enum NetworkServiceFactory {
    static func base() -> NetworkService {
        NetworkServiceBase(
            baseUrl: URL(string: Environment.WeatherURL.value)!,
            apiKey: Environment.WeatherAPIKey.value,
            session: URLSession.shared
        )
    }
}
