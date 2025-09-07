//
//  ListWalksOfTheDaySnippetView.swift
//  Peticle
//
//  Created by Claire on 06/09/2025.
//

import AppIntents
import SwiftUI

struct ListWalksOfTheDaySnippetView: View {
    let walkEntities: [DogWalkEntryEntity]
    
    var body: some View {
        if walkEntities.isEmpty {
            noWalksView
        } else {
            walksList
        }
    }
    
    var walksList: some View {
        ForEach(walkEntities) { walkEntity in
            Button("\(walkEntity.durationInMinutes) min", intent: DeleteWalkIntent(walkEntity: walkEntity))
        }
    }
    
    var noWalksView: some View {
        VStack() {
            Text("WHAT?! No Walk Today!!!")
            Image("Rotated Alfie")
        }
    }
}
