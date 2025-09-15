//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

struct BackupCDNReadCredential: Codable {
    static let lifetime: TimeInterval = .day

    let createDate: Date
    let headers: HttpHeaders

    func isExpired(now: Date) -> Bool {
        return now > createDate.addingTimeInterval(Self.lifetime)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.headers = try container.decode(HttpHeaders.self, forKey: .headers)

        // createDate will default to current date, but can be overwritten during decodable initialization
        self.createDate = try container.decodeIfPresent(Date.self, forKey: .createDate) ?? Date()
    }
}
