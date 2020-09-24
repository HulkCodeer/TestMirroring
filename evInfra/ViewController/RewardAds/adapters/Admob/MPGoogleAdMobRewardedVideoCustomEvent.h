//
//  MPGoogleAdMobRewardedVideoCustomEvent.h
//  evInfra
//
//  Created by Michael Lee on 2020/08/20.
//  Copyright © 2020 soft-berry. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPFullscreenAdAdapter.h"
#endif
#import "MPGoogleGlobalMediationSettings.h"

@interface MPGoogleAdMobRewardedVideoCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
