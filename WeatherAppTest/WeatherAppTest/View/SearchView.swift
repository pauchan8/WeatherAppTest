//
//  SearchView.swift
//  WeatherAppTest
//
//  Created by Pavlo Deynega on 15.12.2024.
//

import SwiftUI

struct SearchView: View {
    @Binding var text: String
    var prompt: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(height: 46)
                .foregroundStyle(.whiteSmoke)
            HStack {
                TextField(prompt, text: $text)
                    .font(FontProvider.regular(size: 15))
                    .padding(.leading, 20)
                Spacer()
                Image("search")
                    .frame(width: 17, height: 17)
                    .padding(.trailing, 15)
            }
        }
    }
}

#Preview {
    SearchView(text: .constant(""), prompt: "Search")
}
