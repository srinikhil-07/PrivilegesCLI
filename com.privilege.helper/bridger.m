//
//  bridger.m
//  com.privilege.helper
//
//  Created by sri-7348 on 3/19/20.
//  Copyright © 2020 Nikhil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bridger.h"

@implementation bridger {
    
}

-(CSIdentityRef) getUserCSIdentityFor:(CBIdentity *)userIdentity {
    return [userIdentity CSIdentity];
}

-(CSIdentityRef) getGroupCSIdentityFor:(CBIdentity *)groupIdentity {
    return [groupIdentity CSIdentity];
}
@end
