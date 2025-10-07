//
//  Onboarding.swift
//  World Time
//
//  Created by Lewis Smith on 06/05/2023.
//  Copyright © 2023 Lasmit TLB. All rights reserved.
//
import Foundation

public struct Onboarding: AnalyticsEvent {

    public var properties: [String : Any]? { return nil }

    public var step: String

    public var name: String {
        return "[Onboarding] \(step)"
    }

    public init(step: String) {
        self.step = step
    }

}
