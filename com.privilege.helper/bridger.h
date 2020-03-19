//
//  bridger.h
//  com.privilege.helper
//
//  Created by sri-7348 on 3/16/20.
//  Copyright © 2020 Nikhil. All rights reserved.
//

#ifndef bridger_h
#define bridger_h


#endif /* bridger_h */
#import <Foundation/Foundation.h>
#import <Collaboration/Collaboration.h>

@interface bridger: NSObject {
    
}
-(CSIdentityRef)getUserCSIdentityFor: (CBIdentity*) userIdentity;
-(CSIdentityRef)getGroupCSIdentityFor: (CBIdentity*) groupIdentity;

@end
