//
//  TPOAuthClient.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPOAuthClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import <SSKeychain/SSKeychain.h>
#import "TPLoginViewController.h"

//NSString * const kBaseURLString = @"https://tide-stage.herokuapp.com";
NSString * const kBaseURLString = @"http://Mayanks-MacBook-Pro.local:7004";

NSString * const kClientId = @"3e372449d494eb6dc7d74cd3da1d6eedd50c7d98f3dedf1caf02960a9a260fb1";
NSString * const kClientSecret = @"3e4da2177beee0d8ec458480526b3716047b3ff0df3362262183f6841253a706";

NSString * const kSSKeychainServiceName = @"Tidepool";

@interface TPOAuthClient()
{
    NSString *_clientId;
    NSString *_clientSecret;
    
}
@end


@implementation TPOAuthClient

+ (TPOAuthClient *)sharedClient;
{
    static TPOAuthClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    _clientId = kClientId;
    _clientSecret = kClientSecret;
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
	[self setDefaultHeader:@"Content-type" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    return self;
}

-(void)savePassword:(NSString *)password forAccount:(NSString *)account
{
    [self deleteAllPasswords];
    [SSKeychain setPassword:password forService:kSSKeychainServiceName account:account];
}

-(void)createAccountWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"password", @"grant_type",
//                            @"password", @"response_type",
                            username, @"email",
                            password, @"password",
                            _clientId, @"client_id",
                            _clientSecret, @"client_secret",
                            nil];
    [self postPath:@"api/v1/users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        [self loginWithUsername:username password:password withCompletingHandlersSuccess:successBlock andFailure:failureBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        NSLog([error description]);
        failureBlock();
    }];
}



-(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"password", @"grant_type",
                            @"password", @"response_type",
                            username, @"email",
                            password, @"password",
                            _clientId, @"client_id",
                            _clientSecret, @"client_secret",
                            nil];
    [self postPath:@"oauth/authorize" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        _oauthAccessToken = [responseObject valueForKey:@"access_token"];
        [self saveAndUseOauthToken:_oauthAccessToken];
//        [self savePassword:password forAccount:username];
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        NSLog([error description]);
        failureBlock();
    }];
}

-(void)saveAndUseOauthToken:(NSString *)token
{
    NSLog(@"called save oauth token");
    [self deleteAllPasswords];
    [SSKeychain setPassword:token forService:kSSKeychainServiceName account:kSSKeychainServiceName];
    NSLog(@"preLOGIN:%@", [self description]);
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",token]];
    NSLog(@"postLOGIN:%@", [self description]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged In" object:self userInfo:nil];
}

-(void)loginAndPresentUI:(bool)presentUI onViewController:(UIViewController *)vc withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    if (accounts.count) {
        NSString *token = [SSKeychain passwordForService:kSSKeychainServiceName account:kSSKeychainServiceName];
        [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",token]];
        successBlock();
        return;
    } else {
        if (presentUI) {
            TPLoginViewController *loginVC = [[TPLoginViewController alloc] init];
            [vc presentViewController:loginVC animated:YES completion:^{}];
        }
    }
}


-(void)deleteAllPasswords
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    for (NSDictionary *account in accounts) {
        NSDictionary *account = accounts[0];
        NSString *username = account[@"acct"];
        [SSKeychain deletePasswordForService:kSSKeychainServiceName account:username];
    }

}

-(void)logout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged Out" object:self userInfo:nil];
    NSLog(@"preLOGOUT:%@", [self description]);
    [self clearAuthorizationHeader];
    NSLog(@"postLOGOUT:%@", [self description]);
    [self deleteAllPasswords];
}

@end
