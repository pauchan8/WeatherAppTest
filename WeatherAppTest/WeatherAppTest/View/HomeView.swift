//
//  HomeView.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @FocusState var keyboardShown: Bool
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        let searchView = SearchView(text: $viewModel.searchQuery, prompt: "Search Location")

        GeometryReader { geometry in
            VStack {
                searchView
                    .padding([.leading, .trailing], 24)
                    .padding(.top, 14)
                    .focused($keyboardShown)
                    .onChange(of: keyboardShown) { oldValue, newValue in
                        if !newValue {
                            viewModel.handleHideKeyboard()
                        }
                    }
                ZStack {
                    ScrollView {
                        VStack {
                            switch viewModel.state {
                            case .initial:
                                ProgressView()
                            case .weatherNotStored:
                                Spacer()
                                    .frame(height: geometry.size.height * 0.295)
                                EmptyView()
                                    .padding([.leading, .trailing], 47)
                            case .searchResults(let results):
                                Spacer()
                                    .frame(height: 32)
                                ForEach(results) { result in
                                    SearchResultView(aggregatedWeatherObject: result)
                                        .padding(.bottom, 16)
                                        .onTapGesture {
                                            viewModel.weatherObjectSelected(result)
                                        }
                                }
                                .padding([.leading, .trailing], 20)
                            case .error(let error):
                                Text(error.localizedDescription)
                            case .storedWeather(let object):
                                CurrentWeatherView(aggregatedWeatherObject: object)
                                    .padding(.top, 50)
                            }
                            Spacer()
                        }
                        .blur(radius: viewModel.isLoading ? 4 : 0)
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.large)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.onStart()
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(state: .storedWeather(AggregatedWeatherObject.sampleObject())))
}
