//
//  ExtensionCompanionRequestHandler.m
//  GPCCompanion
//
//  Created by Arthur Langereis on 2016/6/25.
//  Copyright © 2016 xfinitegames. All rights reserved.
//

#import "ExtensionCompanionRequestHandler.h"

#include "mac_controller.h"


@interface ExtensionCompanionRequestHandler ()

@end

static NSString * const messageNameKey = @"messageName";
static NSString * const messageDataKey = @"messageData";

static Controller* getController() {
	static Controller* controller_s = NULL;
	if (controller_s == NULL) {
		controller_s = [[Controller alloc] init];
	}
	return controller_s;
}

@implementation ExtensionCompanionRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
	Controller* controller = getController();

    NSExtensionItem *message = context.inputItems.firstObject;
    if (!message) {
        // Ignore requests without a message.
        [context completeRequestReturningItems:nil completionHandler:nil];
        return;
    }
    
    NSDictionary *userInfo = message.userInfo;
    NSString *messageName = userInfo[messageNameKey];
    id messageData = userInfo[messageDataKey];
    
    NSLog(@"Companion App Extension: We got a message named: %@ with data %@", messageName, messageData);
    
    NSExtensionItem *response = [[NSExtensionItem alloc] init];
    NSString *responseName = [NSString stringWithFormat:@"Response to '%@'", messageName];
	NSString *responseValue = [NSString stringWithFormat:@"What you said: '%@'", messageName];
	
    NSMutableDictionary *responseUserInfo = [NSMutableDictionary dictionary];
    responseUserInfo[messageNameKey] = responseName;
    if (messageData) {
        responseUserInfo[messageDataKey] = responseValue;
    }
    response.userInfo = responseUserInfo;
    
    [context completeRequestReturningItems:@[ response ] completionHandler:^(BOOL expired) {
        NSLog(@"Companion App Extension: Our completion handler was called");
    }];
}

@end
