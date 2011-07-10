/*
 * Copyright 2011 Jason Rush and John Flanagan. All rights reserved.
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

#import "KdbWriterFactory.h"
#import "Kdb3Writer.h"
#import "Kdb4Writer.h"

@implementation KdbWriterFactory

+ (void)persist:(KdbTree*)tree file:(NSString*)filename withPassword:(NSString*)password {
    id<KdbWriter> writer;
    
    if ([tree isKindOfClass:[Kdb3Tree class]]) {
        writer = [[Kdb3Writer alloc] init];
    } else if ([tree isKindOfClass:[Kdb4Tree class]]) {
        writer = [[Kdb4Writer alloc] init];
    } else {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"IllegalArgument" userInfo:nil];
    }
    
    [writer persist:tree file:filename withPassword:password];
    [writer release];
}

@end