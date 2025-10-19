//
//  LatestActivityIntent.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import AppIntents
import SwiftUI

struct LatestActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Get the last activity"
    static var description = IntentDescription("Return the last activity")
    
    @MainActor
    func perform() async throws -> some ProvidesDialog & ReturnsValue<DogWalkEntryEntity> & ShowsSnippetView {
        
        let dialog = IntentDialog("Here is your last walk data")
        let lastEntry = try await DataModelHelper.lastDogEntry()
        
        return .result(value: lastEntry?.entity ?? DogWalkEntryEntity.init(DogWalkEntry.init(durationInMinutes: 0)), dialog: dialog) {
            
            VStack(alignment: .center) {
                // Entry details
                if let entryDate = lastEntry?.entryDate {
                    Text("\(entryDate.formatted(date: .long, time: .omitted))")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
                
                Text("\(lastEntry?.durationInMinutes ?? 0) mins")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                
                lastEntry?.walkQuality.getWeatherIcon()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .symbolRenderingMode(.multicolor)
            }
            .padding(24)

            .background(.indigo.opacity(0.3),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
