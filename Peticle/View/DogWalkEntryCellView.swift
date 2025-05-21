//
//  DogWalkEntryCellView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

struct DogWalkEntryCellView: View {
    var dogWalkEntry: DogWalkEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dogWalkEntry.entryDate, style: .date)
                    .font(.title2)
                Text(dogWalkEntry.entryDate, style: .time)
                    .font(.headline)
            }
            
            Spacer()
            
            Text("\(dogWalkEntry.durationInMinutes) min")
                .font(.title2)
            
            Spacer()

            dogWalkEntry.dogInteraction.interactionRating.getFusionnedWeatherIcone(with: dogWalkEntry.humainInteraction.interactionRating)
                .resizable()
                .scaledToFill()
                .frame(width: 33, height: 33)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(.gray)
                .symbolEffect(.bounce)
      
        }
    }
}

#Preview {
    DogWalkEntryCellView(dogWalkEntry:DogWalkEntry(durationInMinutes: 23,
                                                   humainInteraction: InteractionEntity.init(interactionCount: 2, interactionRating: .good),
                                                   dogInteraction:  InteractionEntity.init(interactionCount: 2, interactionRating: .good)))
}
