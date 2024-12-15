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
        switch viewModel.state {
        case .locationNotStored:
            Text("No City Selected")
                .font(FontProvider.medium(size: 30))
            Text("Please Search For A City")
                .font(FontProvider.medium(size: 15))
        default:
            Text("Default")
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
