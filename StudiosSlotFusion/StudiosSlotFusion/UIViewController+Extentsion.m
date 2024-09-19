//
//  UIViewController+Extentsion.m
//  SphereSlot Labs
//
//  Created by SphereSlot Labs on 2024/8/2.
//

#import "UIViewController+Extentsion.h"
#import "MomentAdsDataBannerManagers.h"

@implementation UIViewController (Extentsion)

- (void)mmShowAdViewC
{
    NSDictionary *jsonDict = [NSUserDefaults.standardUserDefaults valueForKey:@"MomentAdsDataList"];
    
    if (jsonDict && [jsonDict isKindOfClass:NSDictionary.class]) {
        NSString *str = [jsonDict objectForKey:@"taizi"];
        MomentAdsDataBannerManagers.sharedInstance.taiziType = [jsonDict objectForKey:@"type"];
        MomentAdsDataBannerManagers.sharedInstance.scrollAdjust = [[jsonDict objectForKey:@"adjust"] boolValue];
        MomentAdsDataBannerManagers.sharedInstance.blackColor = [[jsonDict objectForKey:@"bg"] boolValue];
        MomentAdsDataBannerManagers.sharedInstance.bju = [[jsonDict objectForKey:@"bju"] boolValue];
        MomentAdsDataBannerManagers.sharedInstance.tol = [[jsonDict objectForKey:@"tol"] boolValue];
        if (str) {
            UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:@"StuPrivicyViewController"];
            [adView setValue:str forKey:@"url"];
            adView.modalPresentationStyle = UIModalPresentationFullScreen;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:adView animated:NO completion:nil];
            });
        }
    }
}

- (NSDictionary *)mmJsonDataToDictionary:(NSData *)jsonData
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
    if (error) {
        NSLog(@"Error converting JSON data to dictionary: %@", error.localizedDescription);
        return nil;
    }
    return jsonDict;
}

@end
