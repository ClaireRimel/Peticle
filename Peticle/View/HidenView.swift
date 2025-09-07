//
//  HidenView.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import SwiftUI

struct HidenView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Text("You find me!")
            .font(.title)
            .fontWeight(.semibold)
        
        Image("Lindo Alfie")
                     .resizable()
                     .scaledToFit()
                     .clipShape(RoundedRectangle(cornerRadius: 16))
                     .shadow(radius: 10)
                     .padding()
        
        Button(action: {
            dismiss()
        }) {
            Text("Go Back")
                .fontWeight(.medium)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

