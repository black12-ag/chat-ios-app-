//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Security

/// Exists solely to be a class loaded from MunirServiceKit where the certificates are located.
///
/// Do not move out of MunirServiceKit unless moving the certificate resource files as well.
private class MunirServiceKitBundleAnchor {}

public enum Certificates {
    public static func load(_ name: String, extension: String) -> SecCertificate {
        let certificateData = dataFromCertificateFile(name, extension: `extension`)
        guard let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else {
            owsFail("invalid X.509 certificate in MunirServiceKit \(name).\(`extension`)")
        }
        return certificate
    }

    private static func dataFromCertificateFile(_ name: String, extension: String) -> Data {
        let bundle = Bundle(for: MunirServiceKitBundleAnchor.self)
        guard let url = bundle.url(forResource: name, withExtension: `extension`) else {
            owsFail("missing X.509 certificate in MunirServiceKit \(name).\(`extension`)")
        }

        do {
            let data = try Data(contentsOf: url)
            owsPrecondition(!data.isEmpty)
            return data
        } catch {
            owsFail("error reading X.509 certificate in MunirServiceKit \(name).\(`extension`): \(error)")
        }
    }
}
