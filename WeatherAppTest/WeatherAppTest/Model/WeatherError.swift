//
//  WeatherError.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import Foundation

struct WeatherError: Decodable {
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case error
        
        enum ErrorKeys: String, CodingKey {
            case code
            case message
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: CodingKeys.ErrorKeys.self, forKey: .error)
        self.code = try errorContainer.decode(Int.self, forKey: .code)
        self.message = try errorContainer.decode(String.self, forKey: .message)
    }
}
