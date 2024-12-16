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
        GeometryReader { geometry in
            VStack {
                SearchView(text: $viewModel.searchQuery, prompt: "Search Location")
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
                                            keyboardShown = false
                                        }
                                }
                                .padding([.leading, .trailing], 20)
                            case .error(let title, let description):
                                Spacer()
                                    .frame(height: geometry.size.height * 0.1)
                                ErrorView(title: title, description: description)
                                    .padding([.leading, .trailing], 48)
                            case .storedWeather(let object):
                                CurrentWeatherView(aggregatedWeatherObject: object)
                                    .padding(.top, 50)
                            }
                        }
                        .blur(radius: viewModel.isLoading ? 4 : 0)
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.large)
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
