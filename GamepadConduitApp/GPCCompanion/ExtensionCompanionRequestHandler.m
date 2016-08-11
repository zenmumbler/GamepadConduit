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

static NSString * const pollMessage = @"poll";
static NSString * const responseName = @"controllerdata";
static NSString * const responseValue = @"[%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f]";
static NSString * const emptyResponseValue = @"[]";


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
	
	NSExtensionItem *response = [[NSExtensionItem alloc] init];
	
	if ([messageName isEqualToString:pollMessage]) {
		struct ControllerState* cs = [controller state:0];

		NSMutableDictionary *responseUserInfo = [NSMutableDictionary dictionary];
		responseUserInfo[messageNameKey] = responseName;
		if (messageData) {
			if (cs && cs->isExposed) {
				responseUserInfo[messageDataKey] = [NSString stringWithFormat:responseValue,
													packedButtonsState(cs),
													cs->leftStick.posX, cs->leftStick.posY, cs->rightStick.posX, cs->rightStick.posY,
													cs->leftTrigger, cs->rightTrigger];
			}
			else {
				responseUserInfo[messageDataKey] = emptyResponseValue;
			}
		}
		response.userInfo = responseUserInfo;
	}
	
	[context completeRequestReturningItems:@[response] completionHandler:^(BOOL expired) {
		// NSLog(@"Companion App Extension: Our completion handler was called");
	}];
}

@end
