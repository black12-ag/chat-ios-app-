//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

/// Distinguishes which kind of identity we're referring to.
///
/// The ACI ("account identifier") represents the user in question,
/// while the PNI ("phone number identifier") represents the user's phone number (e164).
///
/// And yes, that means the full enumerator names mean "account identifier identity" and
/// "phone number identifier identity".
@objc
public enum OWSIdentity: UInt8 {
    case aci
    case pni
}
