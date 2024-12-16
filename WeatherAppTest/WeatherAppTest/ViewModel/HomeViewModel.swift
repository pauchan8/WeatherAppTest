//
//  HomeViewModel.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    private let weatherService: NetworkService
    private let persistenceService: PersistenceService
    
    @Published var searchQuery: String = ""
    @Published private(set) var state: State
    @Published private(set) var isLoading: Bool = false
    private var didClearSearchQueueManually: Bool = false
    
    private var currentTask: Task<(), Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        weatherService: NetworkService = NetworkServiceFactory.base(),
        persistenceService: PersistenceService = PersistenceServiceBase(),
        state: State = .initial
    ) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
        self.state = state
        bind()
    }
    
    // MARK: - Actions

    func onStart() {
        if state == .initial {
            setUpInitialState()
        }
    }
    
    func weatherObjectSelected(_ weatherObject: AggregatedWeatherObject) {
        didClearSearchQueueManually = true
        searchQuery = ""
        if persistenceService.storeWeather(weatherObject) {
            state = .storedWeather(weatherObject)
        }
    }
    
    func handleHideKeyboard() {
        if searchQuery.isEmpty {
            setUpStoredStateIfPossible()
        }
    }
    
    // MARK: - Helpers
    
    private func setUpInitialState() {
        if let object = persistenceService.latestObject() {
            state = .storedWeather(object)
            isLoading = true
            updateCurrentWeather(object.locationObject)
        } else {
            state = .weatherNotStored
        }
    }
    
    private func setUpStoredStateIfPossible() {
        if let object = persistenceService.latestObject() {
            state = .storedWeather(object)
        } else {
            state = .weatherNotStored
        }
    }
    
    private func search(_ query: String) {
        guard !query.isEmpty else {
            setUpStoredStateIfPossible()
            return
        }
        
        isLoading = true
        currentTask?.cancel()
        currentTask = Task {
            do {
                defer { isLoading = false }
                let locations = try await weatherService.searchLocations(query: query)
                let objects = try await weatherService.batchWeatherObjects(ids: locations.map(\.id))
                var results = [AggregatedWeatherObject]()
                for location in locations {
                    let first = objects.first(where: { $0.locationName == location.name
                        && $0.region == location.region
                        && $0.country == location.country
                    })
                    if let first {
                        results.append(AggregatedWeatherObject(weatherObject: first, locationObject: location))
                    }
                }
                results.sort(by: { $0.weatherObject.locationName < $1.weatherObject.locationName })
                state = .searchResults(results)
            } catch {
                setErrorStateIfNeeded(error)
            }
        }
    }

    private func updateCurrentWeather(_ location: LocationObject) {
        currentTask?.cancel()
        currentTask = Task {
            do {
                let object = try await weatherService.fetchWeather(with: location.id)
                let aggregatedObject = AggregatedWeatherObject(weatherObject: object, locationObject: location)
                state = .storedWeather(aggregatedObject)
                isLoading = false
            } catch {
                setErrorStateIfNeeded(error)
            }
        }
    }
    
    // I've added technical discriptions to errors for simplicity of showing that errors are handled. Of course, in a real life app
    // something like "API key error" should be treated to something more user-friendly.
    private func setErrorStateIfNeeded(_ error: Error) {
        isLoading = false
        if let error = error as? NetworkError {
            switch error {
            case .noLocationMatching:
                state = .error(title: "Not found", description: "No location matching query found.")
            case .apiKeyError(let descr):
                state = .error(title: "API key error", description: descr)
            case .internalError(let descr):
                state = .error(title: "Internal error", description: descr)
            case .invalidData(let descr):
                state = .error(title: "Invalid data", description: "Could not parse data. Description: \(descr).")
            case .invalidResponse(let descr):
                state = .error(title: "Invalid response", description: "Received incorrect response. Description: \(descr).")
            case .invalidURL:
                state = .error(title: "Invalid URL", description: "Could not build URL.")
            case .cancelled:
                isLoading = true
                break
            }
        } else if error is CancellationError {
            isLoading = true
            return
        } else {
            state = .error(title: "Internal error", description: "Could not parse error.")
        }
    }
    
    private func bind() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] query in
                let didClearSearchQueueManually = self?.didClearSearchQueueManually ?? false
                if !didClearSearchQueueManually {
                    self?.search(query)
                } else {
                    self?.didClearSearchQueueManually = false
                }
            }
            .store(in: &cancellables)
    }
}

extension HomeViewModel {
    enum State: Equatable {
        case initial
        case weatherNotStored
        case searchResults([AggregatedWeatherObject])
        case storedWeather(AggregatedWeatherObject)
        case error(title: String, description: String)
    }
}
