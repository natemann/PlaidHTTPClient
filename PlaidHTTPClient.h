//
//  PlaidHTTPClient.h
//  EnvelopeBudget
//
//  Created by Nate on 5/29/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

//You must import AFNetworking for this helper class to function.
//AFNetworking can be found on GitHub or at http://afnetworking.com
//Because of AFNetworking, all GET / POST methods to Plaid are done in the background

#import "AFHTTPSessionManager.h"

@interface PlaidHTTPClient : AFHTTPSessionManager

#define kPlaidBaseURL @"https://tartan.plaid.com"


+ (PlaidHTTPClient *)sharedPlaidHTTPClient;


//Downloads all avalailble institutions available from Plaid.
- (void)downloadPlaidInstitutionsWithCompletionHandler: (void(^)(NSArray * institutions))handler;

//Logins into a specific institution from Plaid with user credentials.
//Pin can be nil.  Not all institutions require a pin.
- (void)loginToInstitution: (NSString *)institutionType
                  userName: (NSString *)userName
                  password: (NSString *)password
                       pin: (NSString *)pin
                     email: (NSString *)email
     withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler;

- (void)submitMFAResponse: (NSString *)mfaResponse
              institution: (NSString *)institutionType
              accessToken: (NSString *)accessToken
    withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler;

//Used to download transactions from a specific institution (accessToken).
//Pending, account, sinceTransaction, get, lte are all option.  Set to nil if not desired option
- (void) downloadTransactionsForAccessToken: (NSString *)accessToken
                                    pending: (BOOL) isPending
                                    account: (NSString *)accountID
                           sinceTransaction: (NSString *)transactionID
                                        gte: (NSDate *)fromDate
                                        lte: (NSDate *)toDate
                                    success: (void(^)(NSURLSessionDataTask *task, NSArray * transactions))handler
                                    failure: (void(^)(NSURLSessionDataTask *task, NSError *error))handler;

//Gets details for specific account
- (void)downloadAccountDetailsForAccessToken: (NSString *)accessToken
                                     account: (NSString *)accountID
                                     success: (void(^)(NSURLSessionDataTask *task, NSDictionary *accountDetails))success
                                     failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)downloadPlaidEntity: (NSString *)entityID
                    success: (void(^)(NSURLSessionDataTask *task, id plaidEntity))success
                    failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
