//
//  DogWalkDetailView.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

struct DogWalkDetailView: View {
    var dogWalkEntry: DogWalkEntry
    @State private var isEditSheetPresented: Bool = false
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    DogWalkDetailView(dogWalkEntry: DogWalkEntry(durationInMinutes: 23,
                                                humainInteraction: InteractionEntity.init(interactionCount: 2,
                                                                                          interactionRating: .good),
                                                dogInteraction:  InteractionEntity.init(interactionCount: 2,
                                                                                        interactionRating: .good)))
}
