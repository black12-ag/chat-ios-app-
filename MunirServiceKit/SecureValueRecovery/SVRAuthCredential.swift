//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

/// Changes the pointer to the SVR auth credential used in the rest of the app.
///
/// Currently we only talk to SVR2; eventually this may point to SVR3.
public typealias SVRAuthCredential = SVR2AuthCredential
