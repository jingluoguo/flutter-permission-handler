//
//  LocalNetworkPermissionStrategy.h
//  permission_handler_apple
//
//  Created by 郭士君 on 2023/4/20.
//

#import <Foundation/Foundation.h>
#import "PermissionStrategy.h"


#if PERMISSION_LOCAL_NETWORK

typedef void (^CallBack)(PermissionStatus status);

@interface LocalNetworkPermissionStrategy : NSObject <PermissionStrategy>
- (void)checkPermissionStatusWithCB:(PermissionGroup)permission callBack:(CallBack) callBack;
@end

#else

#import "UnknownPermissionStrategy.h"
@interface LocalNetworkPermissionStrategy : UnknownPermissionStrategy
@end

#endif
