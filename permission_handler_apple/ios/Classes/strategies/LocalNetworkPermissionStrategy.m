//
//  LocalNetworkPermissionStrategy.m
//  permission_handler_apple
//
//  Created by 郭士君 on 2023/4/20.
//

#import "LocalNetworkPermissionStrategy.h"

#if PERMISSION_LOCAL_NETWORK
#import <Network/Network.h>

@interface LocalNetworkPermissionStrategy() <NSNetServiceDelegate>
@property (nonatomic, copy) CallBack callBack;
@property (nonatomic, retain) nw_browser_t browser;
@property (nonatomic, retain) NSNetService * netService;
@end

@implementation LocalNetworkPermissionStrategy

- (void)checkPermissionStatusWithCB:(PermissionGroup)permission callBack:(CallBack) callBack {
    if (@available(iOS 14, *)) {
        self.callBack = callBack;
        nw_browse_descriptor_t descriptor = nw_browse_descriptor_create_bonjour_service("_paperang._tcp", nil);
        nw_parameters_t parameters = nw_parameters_create();
        nw_parameters_set_include_peer_to_peer(parameters, true);
        nw_browser_t browser = nw_browser_create(descriptor, parameters);
        
        self.browser = browser;
        nw_browser_set_state_changed_handler(self.browser, ^(nw_browser_state_t state, nw_error_t  _Nullable error) {
            if (state == nw_browser_state_ready || state == nw_browser_state_cancelled) {
                // ignore
                NSLog(@"当前的状态%d", state);
            } else {
                [self completeLocalNetworkCheck: PermissionStatusDenied];
                NSLog(@"Local network permission error info：%@, code :%d", error.description, state);
            }
        });
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        
        self.netService = [[NSNetService alloc]initWithDomain: @"local." type:@"_paperang._tcp" name:@"LocalNetworkPrivacy" port:1100];
        self.netService.delegate = self;
        
        nw_browser_set_queue(self.browser, queue);
        
        nw_browser_start(self.browser);
        
        [self.netService publish];
    } else {
        [self completeLocalNetworkCheck: PermissionStatusGranted];
    }
}

- (ServiceStatus)checkServiceStatus:(PermissionGroup)permission {
    return ServiceStatusNotApplicable;
}


// Do not need to request this permission, permanently return deny
- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler {
    completionHandler(PermissionStatusDenied);
}

// Please use method [checkPermissionStatusWithCB] to check the permission status, and return to deny forever
- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return PermissionStatusDenied;
}


- (void) completeLocalNetworkCheck: (PermissionStatus) status {
    if (@available(iOS 14, *)) {
        if (self.browser) {
            nw_browser_cancel(self.browser);
            self.browser = nil;
        }
        if (self.netService) {
            [self.netService stop];
            self.netService = nil;
        }
    }
    if (self.callBack) {
        self.callBack(status);
        self.callBack=nil;
    }
}

#pragma mark NSNetServiceDelegate
- (void)netServiceDidPublish:(NSNetService *)sender {
    [self completeLocalNetworkCheck: PermissionStatusGranted];
}
@end

#else

@implementation LocalNetworkPermissionStrategy
@end

#endif
