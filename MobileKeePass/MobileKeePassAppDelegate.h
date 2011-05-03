//
//  MobileKeePassAppDelegate.h
//  MobileKeePass
//
//  Created by Jason Rush on 4/30/11.
//  Copyright 2011 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseDocument.h"
#import "PasswordEntryController.h"

@interface MobileKeePassAppDelegate : NSObject <UIApplicationDelegate, PasswordEntryControllerDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    UIImage *images[70];
    
    DatabaseDocument *databaseDocument;
}

@property (nonatomic, retain) DatabaseDocument *databaseDocument;

- (UIImage*)loadImage:(int)index;
- (void)openLastDatabase;

@end
