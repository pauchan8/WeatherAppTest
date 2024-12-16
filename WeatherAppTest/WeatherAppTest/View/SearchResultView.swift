//
//  SearchResultView.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import SwiftUI

struct SearchResultView: View {
    let aggregatedWeatherObject: AggregatedWeatherObject
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(height: 117)
                .foregroundStyle(.whiteSmoke)
            HStack {
                VStack(spacing: 10) {
                    Text(aggregatedWeatherObject.locationName)
                        .font(.poppins(.semiBold, size: 20))
                        .foregroundStyle(.nero)
                        .frame(height: 25)
                    HStack(spacing: 0) {
                        Text(aggregatedWeatherObject.teperatureCelsius.trimmedFractionDigits)
                            .font(.poppins(.medium, size: 60))
                            .foregroundStyle(.nero)
                        VStack {
                            Ellipse()
                                .stroke(lineWidth: 1)
                                .frame(width: 5, height: 5)
                            Spacer()
                        }
                    }
                    .padding(.leading, 5)
                    .frame(height: 50)
                }
                .padding(.leading, 31)
                Spacer()
                AsyncImage(url: aggregatedWeatherObject.iconURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .padding(.trailing, 31)
                .frame(height: 67)
            }
        }
    }
}

#Preview {
    SearchResultView(aggregatedWeatherObject: AggregatedWeatherObject.sampleObject())
}
