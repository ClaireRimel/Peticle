//
//  DogWalkEntryCellView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

struct DogWalkEntryCellView: View {
    var dogWalkEntry: DogWalkEntry
    @Environment(NavigationManager.self) private var navigation

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

            dogWalkEntry.walkQuality.getWeatherIcon()
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(.gray)
                .symbolEffect(.bounce)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    DogWalkEntryCellView(dogWalkEntry:DogWalkEntry(durationInMinutes: 23,
                                                   walkQuality: .good))
}
