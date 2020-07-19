//
//  ProtocolServiceManger.h
//  ProtocolServiceManger
//
//  Created by admin on 18/7/2020.
//

#import <Foundation/Foundation.h>

#define ServiceClassWithProtocol(aProtocol) [[ProtocolServiceManger sharedManger] serviceClassWithProtocol:@protocol(aProtocol)]

NS_ASSUME_NONNULL_BEGIN

@interface ProtocolServiceManger : NSObject

+ (instancetype)sharedManger;

- (Class)serviceClassWithProtocol:(Protocol *)aProtocol;

@end

NS_ASSUME_NONNULL_END
