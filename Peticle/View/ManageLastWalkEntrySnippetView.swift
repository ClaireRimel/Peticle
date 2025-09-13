//
//  ManageLastWalkEntrySnippetView.swift
//  Peticle
//
//  Created by Claire on 06/09/2025.
//

import AppIntents
import SwiftUI

struct ManageLastWalkEntrySnippetView: View {
    @State var walkEntity: DogWalkEntryEntity?
    
    var body: some View {
        if let walkEntity {
            actionFor(walkEntity)

        } else {
            noWalksView
        }
    }
    
    func actionFor(_ walkEntity: DogWalkEntryEntity) -> some View {
        VStack {            
            // Entry details
            if let entryDate = walkEntity.entryDate {
                Text("\(entryDate.formatted(date: .long, time: .omitted))")
            }
            
            Text("\(walkEntity.durationInMinutes) min")
            
            walkEntity.dogInteraction?.getFusionnedWeatherIcon(with: walkEntity.humanInteraction ?? InteractionRating.average)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .symbolRenderingMode(.multicolor)
            
            // Action buttons
            VStack(spacing: 10) {
                Button(intent: DeleteWalkIntent(walkEntity: walkEntity)) {
                    Label("Delete Walk", systemImage: "trash")
                        .foregroundColor(.red)
                }
                
                Button(intent: OpenEditEntryIntent(target: walkEntity)) {
                    Label("Edit Walk", systemImage: "pencil")
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(.indigo.opacity(0.3),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
   
    
    var noWalksView: some View {
        VStack() {
            Text("WHAT?! No Walk Today!!!")
            Image("Rotated Alfie")
        }
    }
}
