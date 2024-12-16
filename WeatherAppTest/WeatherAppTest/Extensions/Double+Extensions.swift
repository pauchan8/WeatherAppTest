//
//  Double+Extensions.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import Foundation

extension Double {
    
    var trimmedFractionDigits: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(for: self) ?? ""
    }
}
