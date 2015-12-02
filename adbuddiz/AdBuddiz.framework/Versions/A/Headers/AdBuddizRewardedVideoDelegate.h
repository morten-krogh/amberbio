//
//  AdBuddizRewardedVideoDelegate.h
//  Copyright (c) 2015 Purple Brain. All rights reserved.
//

typedef enum {
    UNIMPLEMENTED = -1
} AdBuddizRewardedVideoError;

@protocol AdBuddizRewardedVideoDelegate <NSObject>

@optional

/*! @brief Called when an Ad has been downloaded and is ready to show. */
- (void)didFetch;

/*! @brief Called when an Ad has been displayed to user. */
- (void)didComplete;

/*! @brief Called when an Ad has been displayed to user. */
- (void)didNotComplete;

/*!
 @brief Called when [AdBuddiz.RewardedVideo show] was called and SDK wasn't able to show an ad.
 @code
 - (void)didFail:(AdBuddizRewardedVideoError) error
 {
 NSLog(@"AdBuddizRewardedVideoDelegate: didFail : %i - %@", error, [AdBuddiz nameForError:error]);
 }
 @endcode
 @param AdBuddizRewardedVideoError code explaining why
 */
- (void)didFail:(AdBuddizRewardedVideoError) error;

@end
