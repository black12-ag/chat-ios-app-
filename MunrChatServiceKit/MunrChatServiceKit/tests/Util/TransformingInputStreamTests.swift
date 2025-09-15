//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import MunrChatServiceKit

final class TransformingInputStreamTests: XCTestCase {
    func testRoundTrip() throws {

        let iv = Randomness.generateRandomBytes(UInt(16))
        let encryptionKey = Randomness.generateRandomBytes(UInt(32))

        let outputStream = TextBackedOutputStream()
        let transformingOutputStream = TransformingOutputStream(
            transforms: [
                ChunkedOutputStreamTransform(),
                try GzipStreamTransform(.compress),
                try EncryptingStreamTransform(iv: iv, encryptionKey: encryptionKey)
            ],
            outputStream: outputStream
        )

        try transformingOutputStream.write(data: "w".data(using: .utf8)!)
        try transformingOutputStream.write(data: "xx".data(using: .utf8)!)
        try transformingOutputStream.write(data: "yyy".data(using: .utf8)!)

        try transformingOutputStream.close()

        let inputData = outputStream.accumulation
        let inputStream = TextBackedInputStream(data: inputData)

        let transformingIntputStream = TransformingInputStream(
            transforms: [
                try DecryptingStreamTransform(encryptionKey: encryptionKey),
                try GzipStreamTransform(.decompress),
                ChunkedInputStreamTransform()
            ],
            inputStream: inputStream
        )

        var results = [Data]()
        while transformingIntputStream.hasBytesAvailable {
            results.append(try transformingIntputStream.read(maxLength: 1024))
        }
        try transformingIntputStream.close()

        XCTAssertEqual(results.filter({$0.count > 0}).count, 3)
    }
}
