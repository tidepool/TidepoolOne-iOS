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

-(BOOL)loginPassively;
-(void)saveAndUseOauthToken:(NSString *)token;

-(NSString *)oauthToken;

-(void)getUserInfoFromServer;

-(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;

-(void)createAccountWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;

-(void)loginFacebookWithTokenInfo:(NSDictionary *)facebookInfo;

-(void)deleteAllPasswords;

-(void)logout;

-(void)authenticateWithFacebookToken:(NSDictionary *)facebookInfo;

-(void)handleError:(NSError *)error withOptionalMessage:(NSString *)message;

-(void)getTidepoolOauthTokenInExchangeForFacebookUserInfo:(NSDictionary *)user andFacebookToken:(NSDictionary *)token;

@end