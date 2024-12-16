//
//  Font+Extensions.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 16.12.2024.
//

import SwiftUICore

extension Font {
    
    enum PoppinsFamilyType {
        /// Weight 400
        case regular
        /// Weight 500
        case medium
        /// Weight 600
        case semiBold
    }
    
    static func poppins(_ familyType: PoppinsFamilyType, size: CGFloat) -> Font {
        let family: String
        switch familyType {
        case .regular: family = "Poppins-Regular"
        case .medium: family = "Poppins-Medium"
        case .semiBold: family = "Poppins-SemiBold"
        }
        return Font.custom(family, size: size)
    }
}
