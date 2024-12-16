//
//  ErrorView.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import SwiftUI

struct ErrorView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.circle")
                .resizable()
                .foregroundStyle(.sting)
                .frame(width: 48, height: 48)
            Text(title)
                .font(.poppins(.medium, size: 25))
                .foregroundStyle(.nero)
            Text(description)
                .font(.poppins(.medium, size: 12))
                .foregroundStyle(.nero)
        }
    }
}

#Preview {
    ErrorView(title: "Error", description: "Could not load data.")
}
