//
//  RateLimits.swift
//  XeroKit
//

import Foundation

/**
 Xero's remaining call allowance, as reported in the headers of the
 most recent response. Xero sends these on every reply, successful or
 not, so the figure is only ever one call stale.

 A limit Xero didn't report on that response is nil rather than a
 guess.
 */
public struct RateLimits: Sendable, Equatable, CustomStringConvertible {
    /// Calls left this minute for this organisation (`X-MinLimit-Remaining`).
    public let minuteRemaining: Int?
    /// Calls left today for this organisation (`X-DayLimit-Remaining`).
    public let dayRemaining: Int?
    /// Calls left this minute for the app across every organisation
    /// (`X-AppMinLimit-Remaining`).
    public let appMinuteRemaining: Int?
    /// When the response carrying these figures arrived.
    public let observedAt: Date

    init?(_ response: Response) {
        minuteRemaining    = response.header("x-minlimit-remaining").flatMap(Int.init)
        dayRemaining       = response.header("x-daylimit-remaining").flatMap(Int.init)
        appMinuteRemaining = response.header("x-appminlimit-remaining").flatMap(Int.init)
        guard minuteRemaining != nil || dayRemaining != nil || appMinuteRemaining != nil
        else { return nil }
        observedAt = .now
    }

    public var description: String {
        func show(_ n: Int?) -> String { n.map(String.init) ?? "?" }
        return "Xero calls left — this minute: \(show(minuteRemaining)), today: \(show(dayRemaining)), app this minute: \(show(appMinuteRemaining))"
    }
}

extension Xero {
    /**
     The allowance reported by the latest Xero response, or nil before
     any response has carried one. Updated in ``postProcess(response:from:)``.
     */
    public internal(set) static var rateLimits: RateLimits?
}
