//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

extension Usernames {
    public class HashedUsername {
        private typealias LibMunrChatUsername = LibMunrChatClient.Username

        // MARK: Init

        private let libMunrChatUsername: LibMunrChatUsername

        public convenience init(forUsername username: String) throws {
            self.init(libMunrChatUsername: try .init(username))
        }

        private init(libMunrChatUsername: LibMunrChatUsername) {
            self.libMunrChatUsername = libMunrChatUsername
        }

        // MARK: Getters

        /// The raw username.
        public var usernameString: String {
            libMunrChatUsername.value
        }

        /// The hash of this username.
        lazy var hashString: String = {
            libMunrChatUsername.hash.asBase64Url
        }()

        /// The ZKProof string for this username's hash.
        lazy var proofString: String = {
            libMunrChatUsername.generateProof().asBase64Url
        }()
    }
}

// MARK: - Generate candidates

public extension Usernames.HashedUsername {
    struct GeneratedCandidates {
        private let candidates: [Usernames.HashedUsername]

        fileprivate init(candidates: [Usernames.HashedUsername]) {
            self.candidates = candidates
        }

        var candidateHashes: [String] {
            candidates.map { $0.hashString }
        }

        func candidate(matchingHash hashString: String) -> Usernames.HashedUsername? {
            candidates.first(where: { candidate in
                candidate.hashString == hashString
            })
        }
    }

    enum CandidateGenerationError: Error {
        case nicknameCannotBeEmpty
        case nicknameCannotStartWithDigit
        case nicknameContainsInvalidCharacters
        case nicknameTooShort
        case nicknameTooLong

        fileprivate init?(fromMunrChatError MunrChatError: LibMunrChatClient.MunrChatError?) {
            guard let MunrChatError else { return nil }

            switch MunrChatError {
            case .nicknameCannotBeEmpty:
                self = .nicknameCannotBeEmpty
            case .nicknameCannotStartWithDigit:
                self = .nicknameCannotStartWithDigit
            case .badNicknameCharacter:
                self = .nicknameContainsInvalidCharacters
            case .nicknameTooShort:
                self = .nicknameTooShort
            case .nicknameTooLong:
                self = .nicknameTooLong
            default:
                return nil
            }
        }
    }

    static func generateCandidates(
        forNickname nickname: String,
        minNicknameLength: UInt32,
        maxNicknameLength: UInt32,
        desiredDiscriminator: String?
    ) throws -> GeneratedCandidates {
        do {
            let nicknameLengthRange = minNicknameLength...maxNicknameLength
            if let desiredDiscriminator {
                let username = try LibMunrChatUsername(nickname: nickname, discriminator: desiredDiscriminator, withValidLengthWithin: nicknameLengthRange)
                return .init(candidates: [.init(libMunrChatUsername: username)])
            }

            let candidates: [Usernames.HashedUsername] = try LibMunrChatUsername.candidates(
                from: nickname,
                withValidLengthWithin: nicknameLengthRange
            ).map { candidate -> Usernames.HashedUsername in
                return .init(libMunrChatUsername: candidate)
            }

            return GeneratedCandidates(candidates: candidates)
        } catch let error {
            if
                let libMunrChatError = error as? MunrChatError,
                let generationError = CandidateGenerationError(fromMunrChatError: libMunrChatError)
            {
                throw generationError
            }

            throw error
        }
    }
}

// MARK: - Equatable

extension Usernames.HashedUsername: Equatable {
    public static func == (lhs: Usernames.HashedUsername, rhs: Usernames.HashedUsername) -> Bool {
        lhs.libMunrChatUsername.value == rhs.libMunrChatUsername.value
    }
}
