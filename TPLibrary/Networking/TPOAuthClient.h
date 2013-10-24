//
//  TPOAuthClient.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//
#import <AFNetworking/AFHTTPClient.h>
#import "TPUser.h"

@interface TPOAuthClient : AFHTTPClient

@property (strong, nonatomic) NSDictionary *user;
@property (assign, nonatomic) BOOL isLoggedIn;
@property (assign, nonatomic) BOOL hasOauthToken;


+ (TPOAuthClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

#pragma mark OAuth methods
-(void)saveAndUseOauthToken:(NSString *)token;
-(NSString *)oauthToken;
-(void)deleteAllPasswords;

#pragma mark Actual Login methods
-(BOOL)loginPassively;
-(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
-(void)createAccountWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
-(void)loginFacebookWithTokenInfo:(NSDictionary *)facebookInfo;
-(void)authenticateWithFacebookToken:(NSDictionary *)facebookInfo;
-(void)logout;

#pragma mark API methods - users
-(void)getUserInfoLocallyIfPossibleWithCompletionHandlersSuccess:(void(^)(NSDictionary *user))successBlock andFailure:(void(^)())failureBlock;
-(void)forceRefreshOfUserInfoFromServerWithCompletionHandlersSuccess:(void(^)(NSDictionary *user))successBlock andFailure:(void(^)())failureBlock;
-(void)updateUserWithParameters:(NSDictionary *)parameters withCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;

#pragma mark API methods - games
-(void)getNewGameOfType:(NSString *)type WithCompletionHandlersSuccess:(void(^)(id dataObject))successBlock andFailure:(void(^)())failureBlock;
-(void)postGameEvents:(NSDictionary *)events withCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
-(void)getGameResultsForGameId:(NSNumber *)gameId WithCompletionHandlersSuccess:(void(^)(id dataObject))successBlock andFailure:(void(^)())failureBlock;

#pragma mark API methods - friends
-(void)findFriendsWithEmail:(NSArray *)emailList;
-(void)findFriendsWithFacebookIds:(NSArray *)facebookIdList;


#pragma mark API methods - connections
-(void)deleteConnectionForProvider:(NSString *)provider;


-(void)handleError:(NSError *)error withOptionalMessage:(NSString *)message;



@end