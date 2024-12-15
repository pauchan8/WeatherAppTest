//
//  HomeViewModel.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    private let weatherService: NetworkService
    private let persistenceService: PersistenceService
    
    @Published var searchQuery: String = ""
    @Published private(set) var state: State
    private(set) var currentWeather: WeatherObject?
    
    private var currentTask: Task<(), Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        weatherService: NetworkService = NetworkServiceFactory.base(),
        persistenceService: PersistenceService = PersistenceServiceBase(),
        state: State = .starting // TODO: think about it
    ) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
        self.state = state
        bind()
        print("---------VIEWMODEL INIT")
    }
    
    // MARK: - Actions

    func onStart() {
        if let object = persistenceService.latestObject() {
            state = .retrievedStoredAndUpdating
            currentWeather = object
            updateWeather()
        } else {
            state = .locationNotStored
        }
    }
    
    func updateWeather() {
        guard let currentWeather else {
            state = .locationNotStored
            return
        }
        
        searchWeather(currentWeather.locationName)
    }
    
    // MARK: - Helpers

    private func searchWeather(_ location: String) {
        currentTask?.cancel()
        currentTask = Task {
            do {
                let object = try await weatherService.fetchWeather(location: location)
                self.currentWeather = object
                state = .loaded
            } catch {
                state = .error(error as! NetworkError)
            }
        }
    }
    
    private func bind() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] query in
                self?.searchWeather(query)
            }
            .store(in: &cancellables)
    }
}

extension HomeViewModel {
    enum State {
        case starting
        case locationNotStored
        case retrievedStoredAndUpdating
        case loaded
        case search(String)
        case error(NetworkError)
    }
}
