//
//  PlaidHTTPClient.m
//  EnvelopeBudget
//
//  Created by Nate on 5/29/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

#import "PlaidHTTPClient.h"

#import "Account.h"
#import "Transaction.h"
#import "Merchant.h"

@interface PlaidHTTPClient ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end



@implementation PlaidHTTPClient

#pragma mark - Setters & Getters

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US_PSIX"]];
        [_dateFormatter setDateFormat: @"yyy-MM-dd"];
    }
    return _dateFormatter;
}



#pragma mark - Public Class Methods

+ (PlaidHTTPClient *)sharedPlaidHTTPClient;
{
    static PlaidHTTPClient *_sharedPlaidHTTPClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                              {
                                  _sharedPlaidHTTPClient = [[self alloc] initWithBaseURL: [NSURL URLWithString: kPlaidBaseURL]];
                              });
    return _sharedPlaidHTTPClient;
}



#pragma mark - Public Instance Methods

- (void) downloadPlaidInstitutionsWithCompletionHandler: (void(^)(NSArray * institutions))handler
{
    [self GET: @"/institutions"
   parameters: nil
      success: ^(NSURLSessionDataTask *task, id responseObject)
               {
                   NSArray *sortedInstitutions = [(NSArray *)responseObject sortedArrayUsingDescriptors: @[[[NSSortDescriptor alloc] initWithKey: @"name"
                                                                                                                                       ascending: YES]]];
                   handler(sortedInstitutions);
               }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
               {
                   NSLog(@"Failed to retrieve Plaid institutions: %@", error.localizedDescription);
               }];
}



- (void) loginToInstitution: (NSString *)institutionType
                   userName: (NSString *)userName
                   password: (NSString *)password
                        pin: (NSString *)pin
                      email: (NSString *)email
      withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler
{
    NSDictionary *credentials     = @{@"username": userName,
                                      @"password": password,
                                      @"pin"     : pin};
    
    NSDictionary *logInParameters = @{@"client_id"  : kClientID,
                                      @"secret"     : kSecret,
                                      @"credentials": credentials,
                                      @"type"       : institutionType,
                                      @"email"      :email};
    
    [self POST: @"/connect"
    parameters: logInParameters
       success: ^(NSURLSessionDataTask *task, id responseObject)
                {
                    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                    
                    handler(response.statusCode, responseObject);
                    
                }
       failure: ^(NSURLSessionDataTask *task, NSError *error)
                {
                    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                    NSLog(@"Unable to login into account with response code : %ld.  Error: %@", (long)response.statusCode, error.localizedDescription);
                    
                    handler(response.statusCode, nil);
                }];
}



- (void) submitMFAResponse: (NSString *)mfaResponse
               institution: (NSString *)institutionType
               accessToken: (NSString *)accessToken
     withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler
{
    NSDictionary *mfaParameters = @{@"client_id"    : kClientID,
                                    @"secret"       : kSecret,
                                    @"mfa"          : mfaResponse,
                                    @"access_token" : accessToken,
                                    @"type"         : institutionType};
    
    [self POST: @"/connect/step"
    parameters: mfaParameters
       success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         
         handler(response.statusCode, responseObject);
     }
       failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSLog(@"Unable to login into account with response code : %ld.  Error: %@", (long)response.statusCode, error.localizedDescription);
         
         handler(response.statusCode, nil);
     }];
}



- (void) downloadTransactionsForAccessToken: (NSString *)accessToken
                                    pending: (BOOL) isPending
                                    account: (NSString *)accountID
                           sinceTransaction: (NSString *)transactionID
                                        gte: (NSDate *)fromDate
                                        lte: (NSDate *)toDate
                                    success: (void(^)(NSURLSessionDataTask *task, NSArray * transactions))success
                                    failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *options = [NSMutableDictionary new];
    
    options[@"pending"] = [NSString stringWithFormat: (isPending ? @"true" : @"false")];
    
    if (accountID)
    {
        options[@"account"] = accountID;
    }
    
    if (transactionID)
    {
        options[@"last"] = transactionID;
    }
    
    if (fromDate)
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        
        [dateFormatter setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US_PSIX"]];
        [dateFormatter setDateFormat: @"yyy-MM-dd"];
        
        options[@"gte"] = [dateFormatter stringFromDate: fromDate];
    }
    
    if (toDate)
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        
        [dateFormatter setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US_PSIX"]];
        [dateFormatter setDateFormat: @"yyy-MM-dd"];
        
        options[@"lte"] = [dateFormatter stringFromDate: toDate];
    }
    
    NSDictionary *dowloadCredentials = @{
                                         @"client_id"     : kClientID,
                                         @"secret"        : kSecret,
                                         @"access_token"  : accessToken,
                                         @"options"       : options
                                         };
    
    [self GET: @"/connect"
   parameters: dowloadCredentials
      success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         NSArray *transactionsArray = (NSArray *)responseObject[@"transactions"];
         success(task, transactionsArray);
     }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         failure(task, error);
     }];
}



- (void)downloadAccountDetailsForAccessToken: (NSString *)accessToken

                                     account: (NSString *)accountID
                                     success: (void(^)(NSURLSessionDataTask *task, NSDictionary *accountDetails))success
                                     failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSDictionary *options             = @{
                                          @"account" : accountID
                                          };
    NSDictionary *downloadCredentials = @{
                                          @"client_id": kClientID,
                                          @"secret"   : kSecret,
                                          @"access_token" : accessToken,
                                          @"options"      : options
                                          };
    
    [self GET: @"/connect"
   parameters: downloadCredentials
      success: ^(NSURLSessionDataTask *task, id responseObject)
               {
                   NSDictionary *accountDictonary = (NSDictionary *)responseObject[@"accounts"][0];
                   success(task, accountDictonary);
               }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
               {
                   failure(task, error);
               }];
}



- (void)downloadPlaidEntity: (NSString *)entityID
                    success: (void(^)(NSURLSessionDataTask *task, id plaidEntity))success
                    failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self GET: [NSString stringWithFormat: @"/entitities/%@", entityID]
   parameters: nil
      success: ^(NSURLSessionDataTask *task, id responseObject)
               {
                   success(task, responseObject);
               }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
               {
                   failure(task, error);
               }];
}



#pragma mark - Private Methods

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL: url];
    
    if (self)
    {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer  = [AFJSONRequestSerializer serializer];
    }
    return self;
}


@end
