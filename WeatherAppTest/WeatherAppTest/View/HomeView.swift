//
//  HomeView.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            SearchView(text: $viewModel.searchQuery, prompt: "Search Location")
                .padding([.leading, .trailing], 24)
                .padding(.top, 14)
            switch viewModel.state {
            case .locationNotStored:
                Text("No City Selected")
                    .font(FontProvider.medium(size: 30))
                Text("Please Search For A City")
                    .font(FontProvider.medium(size: 15))
            default:
                Text("Default")
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
