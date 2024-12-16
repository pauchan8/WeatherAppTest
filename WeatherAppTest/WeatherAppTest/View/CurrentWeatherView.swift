//
//  CurrentWeatherView.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import SwiftUI

struct CurrentWeatherView: View {
    let aggregatedWeatherObject: AggregatedWeatherObject
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: aggregatedWeatherObject.iconURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 123, height: 123)
            HStack(spacing: 11) {
                Text(aggregatedWeatherObject.locationName)
                    .font(.poppins(.semiBold, size: 30))
                    .foregroundStyle(.nero)
                Image("arrow")
                    .frame(width: 21, height: 21)
            }
            .padding(.leading, 21)
            HStack(spacing: 0) {
                Text(aggregatedWeatherObject.teperatureCelsius.trimmedFractionDigits)
                    .font(.poppins(.medium, size: 70))
                    .foregroundStyle(.nero)
                    Ellipse()
                        .stroke(lineWidth: 1)
                        .frame(width: 8, height: 8)
                        .padding(.bottom, 60)
            }
            .padding(.leading, 8)
            .padding(.top, 5)
            Spacer()
                .frame(height:25)
            CurrentWeatherDetailsView(weatherObject: aggregatedWeatherObject.weatherObject)
                .padding(.leading, 57)
                .padding(.trailing, 44)
        }
        Spacer()
    }
}

struct CurrentWeatherDetailsView: View {
    let weatherObject: WeatherObject
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.whiteSmoke)
            HStack {
                VStack {
                    Text("Humidity")
                        .font(.poppins(.regular, size: 12))
                        .foregroundStyle(.silver)
                    Text("\(weatherObject.humidity.trimmedFractionDigits)%")
                        .font(.poppins(.regular, size: 15))
                        .foregroundStyle(.nobel)
                }
                .padding(.leading, 16)
                Spacer()
                VStack {
                    Text("UV")
                        .font(.poppins(.regular, size: 12))
                        .foregroundStyle(.silver)
                    Text("\(weatherObject.uv.trimmedFractionDigits)%")
                        .font(.poppins(.regular, size: 15))
                        .foregroundStyle(.nobel)
                }
                Spacer()
                VStack {
                    Text("Feels Like")
                        .font(.poppins(.regular, size: 12))
                        .foregroundStyle(.silver)
                    Text("\(weatherObject.feelsLikeCelsius.trimmedFractionDigits)%")
                        .font(.poppins(.regular, size: 15))
                        .foregroundStyle(.nobel)
                }
                .padding(.trailing, 28)
            }
        }
        .frame(height: 75)
    }
}

#Preview {
    CurrentWeatherView(aggregatedWeatherObject: AggregatedWeatherObject.sampleObject())
}
