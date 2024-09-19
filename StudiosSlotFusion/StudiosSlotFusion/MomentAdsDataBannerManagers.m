//
//  ApexDataManagers.m
//  SphereSlot Labs
//
//  Created by SphereSlot Labs on 2024/8/2.
//

#import "MomentAdsDataBannerManagers.h"

@implementation MomentAdsDataBannerManagers

+ (instancetype)sharedInstance {
    static MomentAdsDataBannerManagers *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.taiziType = @"wg";
    }
    return self;
}

- (void)setTaiziType:(NSString *)taiziType
{
    _taiziType = taiziType;
    if ([taiziType isEqualToString:@"wg"]) {
        self.type = SpAdsDataBannerWG;
    } else if ([taiziType isEqualToString:@"pd"]) {
        self.type = SpAdsDataBannerPD;
    } else if ([taiziType isEqualToString:@"bl"]) {
        self.type = SpAdsDataBannerBL;
    }
}

@end
