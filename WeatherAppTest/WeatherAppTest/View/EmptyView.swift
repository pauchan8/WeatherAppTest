//
//  EmptyView.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        Text("No City Selected")
            .font(.poppins(.medium, size: 30))
        Text("Please Search For A City")
            .font(.poppins(.medium, size: 15))
            .padding(.top, -15)
    }
}

#Preview {
    EmptyView()
}
