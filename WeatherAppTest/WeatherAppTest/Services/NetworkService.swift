//
//  NetworkService.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse(String)
    case invalidData(String)
    case noLocationMatching
    case apiKeyError(String)
    case internalError(String)
    case cancelled
    
    init?(weatherError: WeatherError) {
        switch weatherError.code {
        case 1006:
            self = .noLocationMatching
        case 9999:
            self = .internalError("Server issues: " + weatherError.message)
        case 2006...2009:
            self = .apiKeyError("Server description: " + weatherError.message)
        default:
            return nil
        }
    }
}

protocol NetworkService {
    func fetchWeather(with id: Int) async throws -> WeatherObject
    func searchLocations(query: String) async throws -> [LocationObject]
    func batchWeatherObjects(ids: [Int]) async throws -> [WeatherObject]
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
    
    func searchLocations(query: String) async throws -> [LocationObject] {
        let fetchURL = try url(for: "search.json", query: query)
        let responseTuple = try await response(for: fetchURL)
        return try handleResponse(data: responseTuple.0, response: responseTuple.1)
    }
    
    func batchWeatherObjects(ids: [Int]) async throws -> [WeatherObject] {
        return try await withThrowingTaskGroup(of: WeatherObject.self) { group in
            ids.forEach { id in
                group.addTask {
                    try await self.fetchWeather(with: id)
                }
            }
            
            var results: [WeatherObject] = []
            for try await object in group {
                results.append(object)
            }
            return results
        }
    }
    
    func fetchWeather(with id: Int) async throws -> WeatherObject {
        let fetchURL = try url(for: "current.json", query: "id:\(id)")
        let responseTuple = try await response(for: fetchURL)
        return try handleResponse(data: responseTuple.0, response: responseTuple.1)
    }
    
    // MARK: - Helpers
    
    private func url(for path: String, query: String) throws -> URL {
        var fetchComponents = URLComponents(url: baseUrl.appending(path: path), resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "aqi", value: "no")
        ]
        
        if let fetchURL = fetchComponents?.url {
            return fetchURL
        } else {
            throw NetworkError.invalidURL
        }
    }
    
    private func response(for url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(from: url)
        } catch {
            if (error as NSError).code == -999 {
                throw NetworkError.cancelled
            } else {
                throw NetworkError.invalidResponse(error.localizedDescription)
            }
        }
    }
    
    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let decodedError = try? JSONDecoder().decode(WeatherError.self, from: data)
            let error = decodedError.flatMap { NetworkError(weatherError: $0) }
            throw error ?? NetworkError.invalidResponse("Could not decode response error.")
        }

        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            throw NetworkError.invalidData(error.localizedDescription)
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
