/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "AppSettings.h"
#import "KeychainUtils.h"
#import "PasswordUtils.h"

#define VERSION                    @"version"
#define EXIT_TIME                  @"exitTime"
#define PIN_ENABLED                @"pinEnabled"
#define PIN                        @"PIN"
#define PIN_LOCK_TIMEOUT           @"pinLockTimeout"
#define PIN_FAILED_ATTEMPTS        @"pinFailedAttempts"
#define BIOMETRIC_AUTH_ENABLED     @"biometricAuthEnabled"
#define DELETE_ON_FAILURE_ENABLED  @"deleteOnFailureEnabled"
#define DELETE_ON_FAILURE_ATTEMPTS @"deleteOnFailureAttempts"
#define CLOSE_ENABLED              @"closeEnabled"
#define CLOSE_TIMEOUT              @"closeTimeout"
#define REMEMBER_PASSWORDS_ENABLED @"rememberPasswordsEnabled"
#define CONFIRM_REMEMBER_PASSWORDS @"confirmRememberPasswords"
#define HIDE_PASSWORDS             @"hidePasswords"
#define SORT_ALPHABETICALLY        @"sortAlphabetically"
#define SEARCH_TITLE_ONLY          @"searchTitleOnly"
#define PASSWORD_ENCODING          @"passwordEncoding"
#define CLEAR_CLIPBOARD_ENABLED    @"clearClipboardEnabled"
#define BACKUP_DISABLED            @"backupDisabled"
#define CLEAR_CLIPBOARD_TIMEOUT    @"clearClipboardTimeout"
#define WEB_BROWSER_INTEGRATED     @"webBrowserIntegrated"
#define PW_GEN_LENGTH              @"pwGenLength"
#define PW_GEN_CHAR_SETS           @"pwGenCharSets"

@interface AppSettings () {
    NSUserDefaults *userDefaults;
}
@end

@implementation AppSettings

static NSInteger pinLockTimeoutValues[] = {
    0,
    30,
    60,
    120,
    300
};

static NSInteger deleteOnFailureAttemptsValues[] = {
    3,
    5,
    10,
    15
};

static NSInteger closeTimeoutValues[] = {
    0,
    30,
    60,
    120,
    300
};

static NSInteger clearClipboardTimeoutValues[] = {
    30,
    60,
    120,
    180
};

static NSStringEncoding passwordEncodingValues[] = {
    NSUTF8StringEncoding,
    NSUTF16BigEndianStringEncoding,
    NSUTF16LittleEndianStringEncoding,
    NSISOLatin1StringEncoding,
    NSISOLatin2StringEncoding,
    NSASCIIStringEncoding,
    NSJapaneseEUCStringEncoding,
    NSISO2022JPStringEncoding
};

static AppSettings *sharedInstance;

+ (void)initialize {
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedInstance = [[AppSettings alloc] init];
    }
}

+ (AppSettings *)sharedInstance {
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.io.brevans.Kagi"];

        // Register the default values
        NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
        [defaultsDict setValue:[NSNumber numberWithBool:YES] forKey:BIOMETRIC_AUTH_ENABLED];
        [defaultsDict setValue:[NSNumber numberWithBool:NO] forKey:DELETE_ON_FAILURE_ENABLED];
        [defaultsDict setValue:[NSNumber numberWithInt:1] forKey:DELETE_ON_FAILURE_ATTEMPTS];
        [defaultsDict setValue:[NSNumber numberWithBool:YES] forKey:CLOSE_ENABLED];
        [defaultsDict setValue:[NSNumber numberWithInt:4] forKey:CLOSE_TIMEOUT];
        [defaultsDict setValue:[NSNumber numberWithBool:NO] forKey:REMEMBER_PASSWORDS_ENABLED];
        [defaultsDict setValue:[NSNumber numberWithBool:NO] forKey:CONFIRM_REMEMBER_PASSWORDS];
        [defaultsDict setValue:[NSNumber numberWithBool:YES] forKey:HIDE_PASSWORDS];
        [defaultsDict setValue:[NSNumber numberWithBool:YES] forKey:SORT_ALPHABETICALLY];
        [defaultsDict setValue:[NSNumber numberWithBool:NO] forKey:SEARCH_TITLE_ONLY];
        [defaultsDict setValue:[NSNumber numberWithInt:0] forKey:PASSWORD_ENCODING];
        [defaultsDict setValue:[NSNumber numberWithBool:NO] forKey:CLEAR_CLIPBOARD_ENABLED];
        [defaultsDict setValue:[NSNumber numberWithInt:0] forKey:CLEAR_CLIPBOARD_TIMEOUT];
        [defaultsDict setValue:[NSNumber numberWithBool:NO] forKey:BACKUP_DISABLED];
        [defaultsDict setValue:[NSNumber numberWithBool:YES] forKey:WEB_BROWSER_INTEGRATED];
        [defaultsDict setValue:[NSNumber numberWithInt:10] forKey:PW_GEN_LENGTH];
        [defaultsDict setValue:[NSNumber numberWithInt:0x07] forKey:PW_GEN_CHAR_SETS];
        [userDefaults registerDefaults:defaultsDict];
    }
    return self;
}

- (NSString *)version {
    return [userDefaults stringForKey:VERSION];
}

- (void)setVersion:(NSString *)version {
    return [userDefaults setValue:version forKey:VERSION];
}

- (NSDate *)exitTime {
    NSString *string = [KeychainUtils stringForKey:EXIT_TIME andServiceName:KEYCHAIN_PIN_SERVICE];
    if (string == nil) {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[string doubleValue]];
}

- (void)setExitTime:(NSDate *)exitTime {
    NSNumber *number = [NSNumber numberWithDouble:[exitTime timeIntervalSinceReferenceDate]];
    [KeychainUtils setString:[number stringValue] forKey:EXIT_TIME andServiceName:KEYCHAIN_PIN_SERVICE];
}

- (BOOL)pinEnabled {
    NSString *string = [KeychainUtils stringForKey:PIN_ENABLED andServiceName:KEYCHAIN_PIN_SERVICE];
    if (string == nil) {
        return NO;
    }
    return [string boolValue];
}

- (void)setPinEnabled:(BOOL)pinEnabled {
    NSNumber *number = [NSNumber numberWithBool:pinEnabled];
    [KeychainUtils setString:[number stringValue] forKey:PIN_ENABLED andServiceName:KEYCHAIN_PIN_SERVICE];
}

- (NSString *)pin {
    return [KeychainUtils stringForKey:PIN andServiceName:KEYCHAIN_PIN_SERVICE];
}

- (void)setPin:(NSString *)pin {
    [KeychainUtils setString:pin forKey:PIN andServiceName:KEYCHAIN_PIN_SERVICE];
}

- (NSInteger)pinLockTimeout {
    NSInteger pinLockTimeoutIndex = [self pinLockTimeoutIndex];
    return pinLockTimeoutValues[pinLockTimeoutIndex];
}

- (NSInteger)pinLockTimeoutIndex {
    NSString *string = [KeychainUtils stringForKey:PIN_LOCK_TIMEOUT andServiceName:KEYCHAIN_PIN_SERVICE];
    if (string == nil) {
        return 1; // Default Value
    }
    return [string intValue];
}

- (void)setPinLockTimeoutIndex:(NSInteger)pinLockTimeoutIndex {
    NSNumber *number = [NSNumber numberWithInteger:pinLockTimeoutIndex];
    [KeychainUtils setString:[number stringValue] forKey:PIN_LOCK_TIMEOUT andServiceName:KEYCHAIN_PIN_SERVICE];
}

- (NSInteger)pinFailedAttempts {
    NSString *string = [KeychainUtils stringForKey:PIN_FAILED_ATTEMPTS andServiceName:KEYCHAIN_PIN_SERVICE];
    if (string == nil) {
        return 0;
    }
    return [string integerValue];
}

- (void)setPinFailedAttempts:(NSInteger)pinFailedAttempts {
    NSNumber *number = [NSNumber numberWithInteger:pinFailedAttempts];
    [KeychainUtils setString:[number stringValue] forKey:PIN_FAILED_ATTEMPTS andServiceName:KEYCHAIN_PIN_SERVICE];
}

- (BOOL)deleteOnFailureEnabled {
    return [userDefaults boolForKey:DELETE_ON_FAILURE_ENABLED];
}

- (BOOL)biometricsEnabled {
    return [userDefaults boolForKey:BIOMETRIC_AUTH_ENABLED];
}

- (void)setBiometricsEnabled:(BOOL)biometricsEnabled {
    [userDefaults setBool:biometricsEnabled forKey:BIOMETRIC_AUTH_ENABLED];
}

- (void)setDeleteOnFailureEnabled:(BOOL)deleteOnFailureEnabled {
    [userDefaults setBool:deleteOnFailureEnabled forKey:DELETE_ON_FAILURE_ENABLED];
}

- (NSInteger)deleteOnFailureAttempts {
    return deleteOnFailureAttemptsValues[[userDefaults integerForKey:DELETE_ON_FAILURE_ATTEMPTS]];
}

- (NSInteger)deleteOnFailureAttemptsIndex {
    return [userDefaults integerForKey:DELETE_ON_FAILURE_ATTEMPTS];
}

- (void)setDeleteOnFailureAttemptsIndex:(NSInteger)deleteOnFailureAttemptsIndex {
    [userDefaults setInteger:deleteOnFailureAttemptsIndex forKey:DELETE_ON_FAILURE_ATTEMPTS];
}

- (BOOL)closeEnabled {
    return [userDefaults boolForKey:CLOSE_ENABLED];
}

- (void)setCloseEnabled:(BOOL)closeEnabled {
    [userDefaults setBool:closeEnabled forKey:CLOSE_ENABLED];
}

- (NSInteger)closeTimeout {
    return closeTimeoutValues[[userDefaults integerForKey:CLOSE_TIMEOUT]];
}

- (NSInteger)closeTimeoutIndex {
    return [userDefaults integerForKey:CLOSE_TIMEOUT];
}

- (void)setCloseTimeoutIndex:(NSInteger)closeTimeoutIndex {
    [userDefaults setInteger:closeTimeoutIndex forKey:CLOSE_TIMEOUT];
}

- (BOOL)rememberPasswordsEnabled {
    return [userDefaults boolForKey:REMEMBER_PASSWORDS_ENABLED];
}

- (void)setRememberPasswordsEnabled:(BOOL)rememberPasswordsEnabled {
    [userDefaults setBool:rememberPasswordsEnabled forKey:REMEMBER_PASSWORDS_ENABLED];
}

- (BOOL)didConfirmRememberingPasswords {
    return [userDefaults boolForKey:CONFIRM_REMEMBER_PASSWORDS];
}

- (void)setDidConfirmRememberingPasswords:(BOOL)didConfirm {
    [userDefaults setBool:didConfirm forKey:CONFIRM_REMEMBER_PASSWORDS];
}

- (BOOL)hidePasswords {
    return [userDefaults boolForKey:HIDE_PASSWORDS];
}

- (void)setHidePasswords:(BOOL)hidePasswords {
    [userDefaults setBool:hidePasswords forKey:HIDE_PASSWORDS];
}

- (BOOL)sortAlphabetically {
    return [userDefaults boolForKey:SORT_ALPHABETICALLY];
}

- (void)setSortAlphabetically:(BOOL)sortAlphabetically {
    [userDefaults setBool:sortAlphabetically forKey:SORT_ALPHABETICALLY];
}

- (BOOL)searchTitleOnly {
    return [userDefaults boolForKey:SEARCH_TITLE_ONLY];
}

- (void)setSearchTitleOnly:(BOOL)searchTitleOnly {
    [userDefaults setBool:searchTitleOnly forKey:SEARCH_TITLE_ONLY];
}

- (NSStringEncoding)passwordEncoding {
    return passwordEncodingValues[[userDefaults integerForKey:PASSWORD_ENCODING]];
}

- (NSInteger)passwordEncodingIndex {
    return [userDefaults integerForKey:PASSWORD_ENCODING];
}

- (void)setPasswordEncodingIndex:(NSInteger)passwordEncodingIndex {
    [userDefaults setInteger:passwordEncodingIndex forKey:PASSWORD_ENCODING];
}

- (BOOL)clearClipboardEnabled {
    return [userDefaults boolForKey:CLEAR_CLIPBOARD_ENABLED];
}

- (void)setClearClipboardEnabled:(BOOL)clearClipboardEnabled {
    [userDefaults setBool:clearClipboardEnabled forKey:CLEAR_CLIPBOARD_ENABLED];
}

- (NSInteger)clearClipboardTimeout {
    return clearClipboardTimeoutValues[[userDefaults integerForKey:CLEAR_CLIPBOARD_TIMEOUT]];
}

- (NSInteger)clearClipboardTimeoutIndex {
    return [userDefaults integerForKey:CLEAR_CLIPBOARD_TIMEOUT];
}

- (void)setClearClipboardTimeoutIndex:(NSInteger)clearClipboardTimeoutIndex {
    [userDefaults setInteger:clearClipboardTimeoutIndex forKey:CLEAR_CLIPBOARD_TIMEOUT];
}

- (BOOL)webBrowserIntegrated {
    return [userDefaults boolForKey:WEB_BROWSER_INTEGRATED];
}

- (void)setWebBrowserIntegrated:(BOOL)webBrowserIntegrated {
    [userDefaults setBool:webBrowserIntegrated forKey:WEB_BROWSER_INTEGRATED];
}

- (NSInteger)pwGenLength {
    return [userDefaults integerForKey:PW_GEN_LENGTH];
}

- (void)setPwGenLength:(NSInteger)pwGenLength {
    [userDefaults setInteger:pwGenLength forKey:PW_GEN_LENGTH];
}

- (NSInteger)pwGenCharSets {
    return [userDefaults integerForKey:PW_GEN_CHAR_SETS];
}

- (void)setPwGenCharSets:(NSInteger)pwGenCharSets {
    [userDefaults setInteger:pwGenCharSets forKey:PW_GEN_CHAR_SETS];
}

@end
