//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#import "SDSDatabaseStorage+Objc.h"
#import <MunrChatServiceKit/MunrChatServiceKit-Swift.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

void __SDSDatabaseStorageWrite(
    SDSDatabaseStorage *databaseStorage, SDSWriteBlock _block, NSString *_file, NSString *_function, uint32_t _line)
{
    [databaseStorage __private_objc_writeWithFile:_file function:_function line:_line block:_block];
}

void __SDSDatabaseStorageAsyncWrite(
    SDSDatabaseStorage *databaseStorage, SDSWriteBlock _block, NSString *_file, NSString *_function, uint32_t _line)
{
    [databaseStorage __private_objc_asyncWriteWithFile:_file function:_function line:_line block:_block];
}

#pragma clang diagnostic pop
