//
//  FontProvider.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import SwiftUICore

enum FontProvider {
    
    // Weight 400
    static func regular(size: CGFloat) -> Font {
        Font.custom("Poppins-Regular", size: size)
    }
    
    // Weight 500
    static func medium(size: CGFloat) -> Font {
        Font.custom("Poppins-Medium", size: size)
    }
    
    // Weight 600
    static func semiBold(size: CGFloat) -> Font {
        Font.custom("Poppins-SemiBold", size: size)
    }
}
