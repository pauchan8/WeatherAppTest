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
    @Published private(set) var isLoading = false
    
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
        if persistenceService.storeWeather(weatherObject) {
            state = .storedWeather(weatherObject)
        }
        // TODO: add error handling with snack bar?
    }
    
    func handleHideKeyboard() {
        if searchQuery == "" {
            setUpInitialState()
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
    
    private func search(_ query: String) {
        guard !query.isEmpty else {
            state = .searchResults([])
            return
        }
        
        isLoading = true
        currentTask?.cancel()
        currentTask = Task {
            do {
                let locations = try await weatherService.searchLocations(query: query)
                let objects = try await weatherService.batchLocations(locations: locations)
                let results = objects.sorted(by: { $0.weatherObject.locationName < $1.weatherObject.locationName })
                state = .searchResults(results)
                isLoading = false
            } catch {
                setErrorState(error)
            }
        }
    }

    private func updateCurrentWeather(_ location: LocationObject) {
        currentTask?.cancel()
        currentTask = Task {
            do {
                let object = try await weatherService.fetchWeather(with: location)
                state = .storedWeather(object)
                isLoading = false
            } catch {
                setErrorState(error)
            }
        }
    }
    
    private func setErrorState(_ error: Error) {
        isLoading = false
        if let error = error as? NetworkError {
            state = .error(error)
        } else {
            state = .error(.internalError("Could not parse error"))
        }
    }
    
    private func bind() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] query in
                self?.search(query)
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
        case error(NetworkError)
    }
}
