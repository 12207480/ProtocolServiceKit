//
//  ProtocolServiceManger.m
//  ProtocolServiceManger
//
//  Created by DevDragonli on 18/7/2020.
//

#import "ProService.h"

static NSString *const ProServiceProtocolStringID = @"Protocol";

static NSString *const ProServiceClassStringID = @"Service";

@interface ProService ()

/**@property (nonatomic, strong) dispatch_queue_t asyncProServiceKitOperationQueue;*/

/// Map < Key:protocolKey Value:serviceClassString > 
@property (nonatomic,strong,nullable) NSMutableDictionary < NSString *, NSString * > * mapDics;

/// cache < Value:serviceClass = Key:protocol >
@property (nonatomic,strong,nullable) NSMutableDictionary <NSString * , Class > * cacheDics;

@end

@implementation ProService

+ (instancetype)sharedManger {
    static dispatch_once_t once;
    static ProService *sharedManger;
    dispatch_once(&once, ^{
        sharedManger = [[[self class] alloc] init];
    });
    return sharedManger;
}

- (Class)serviceClassWithProtocol:(Protocol *)aProtocol {
    return [self serviceClassWithProtocol:aProtocol isCache:NO];
}

#pragma mark - cache serviceClass Method

- (Class)serviceClassWithCachedProtocol:(Protocol *)cachedProtocol {
    // frist try cacheServiceClass
    Class cacheServiceClass = [self.cacheDics objectForKey:NSStringFromProtocol(cachedProtocol)];
    if (cacheServiceClass) {
        // if cahched Service,can return it!
        return cacheServiceClass;
    } else {
        return [self serviceClassWithProtocol:cachedProtocol isCache:YES];
    }
}

- (Class)serviceClassWithProtocol:(Protocol *)aProtocol
                          isCache:(BOOL)isCache {
    // current Protocol is Exist
    if (!aProtocol) {
        NSAssert(self.ignoreSafeMode, @"【ProtocolServiceKit：】This protocol not exist !");
        return nil;
    }
    // Normal Service Class
    NSString *serviceClassString = [NSStringFromProtocol(aProtocol) stringByReplacingOccurrencesOfString:ProServiceProtocolStringID withString:ProServiceClassStringID];
    Class serviceClass = NSClassFromString(serviceClassString);
    if (!serviceClass) {
        // rule Class -> MapType Class
        serviceClass = [self tryMapServiceClassWithProtocol:aProtocol];
        
        if (!serviceClass) {
            NSAssert(self.ignoreSafeMode, @"【ProtocolServiceKit：】no implementation Map Service Class]");
        }
        return serviceClass;
    }
    
    if (!serviceClass) {
        NSAssert(self.ignoreSafeMode, @"【ProtocolServiceKit：】no implementation classe[Rule&&Map Class]");
        return nil;
    }
    
    return [self checkServiceClass:serviceClass aProtocol:aProtocol isCache:isCache];
}

#pragma mark - check Service Class

- (Class)checkServiceClass:(Class)serviceClass
                 aProtocol:(Protocol *)aProtocol
                   isCache:(BOOL)isCache {
    // make Sure implClass conformsToProtocol then return ServiceClass
    if (serviceClass && [serviceClass conformsToProtocol:aProtocol]) {
        if (isCache) {
            [self.cacheDics setValue:serviceClass forKey:NSStringFromProtocol(aProtocol)];
        }
        return serviceClass;
    } else {
        NSAssert(self.ignoreSafeMode, @"【ProtocolServiceKit：】Current Class Not implementation Method or Not exist Service Class");
        return nil;
    }
}

#pragma mark - map

- (Class)tryMapServiceClassWithProtocol:(Protocol *)aProtocol {
    NSString *mapClassString = [self.mapDics objectForKey:NSStringFromProtocol(aProtocol)];
    NSLog(@"%@",mapClassString);
    return NSClassFromString(mapClassString);
}

- (void)configProtocolServiceMapsWithDic:(NSDictionary < NSString * ,NSString *>*)mapDics {
    [mapDics enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull protocolKey, NSString *  _Nonnull serviceClassString, BOOL * _Nonnull stop) {
        [self.mapDics setValue:serviceClassString forKey:protocolKey];
    }];
}

#pragma mark lazy propertys

- (NSMutableDictionary<NSString *,Class> *)cacheDics {
    if (!_cacheDics) {
        _cacheDics = [NSMutableDictionary dictionary];
    }
    return _cacheDics;
}

- (NSMutableDictionary<NSString *,NSString *> *)mapDics {
    if (!_mapDics) {
        _mapDics = [NSMutableDictionary dictionary];
    }
    return _mapDics;
}

@end
