//
//  Onboarding.swift
//  World Time
//
//  Created by Lewis Smith on 06/05/2023.
//  Copyright © 2023 Lasmit TLB. All rights reserved.
//
import Foundation

struct Onboarding: AnalyticsEvent {
    
    var properties: [String : Any]? { return nil }
    
    var step: String
    
    var name: String {
        return "[Onboarding] \(step)"
    }
  
}
