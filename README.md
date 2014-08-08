PlaidHTTPClient
===============

Objective-C Helper Methods to interact with Plaid.com.  These classes are a subclass of AFNetworking.  You must have AFNetworking as a part of your project for these methods to work.  AFNetworking can be found at http://afnetworking.com

###Prerequisites

Nearly all methods require a Plaid ClientID and a Plaid Secret.  You can sign up to receive these at http://plaid.com

Import AFNetworking into your project.  PlaidHTTPClient is a subclass of AFHTTPSessionManager

###Methods
First create an singleton instance of PlaidHTTPClient with

```Objective-C
+ (PlaidHTTPClient *)sharedPlaidHTTPClient;
```

All methods are performed in the background with the responses from Plaid in the form of a completion handler.  

#####Retrieve All Institutions

```Objective-C
- (void)downloadPlaidInstitutionsWithCompletionHandler: (void(^)(NSArray * institutions))handler;
```

institutions will be an array of NSDictionaries

####Log In to Institution
Once an institution is selected, you can log into the institution with 

```Objective-C
- (void)loginToInstitution: (NSString *)institutionType
                  userName: (NSString *)userName
                  password: (NSString *)password
                       pin: (NSString *)pin
                     email: (NSString *)email
     withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler;
```

'pin' is optional.  If the institution does not require one, set to nil.  userAccounts will indicate if an MFA authentication is required.  Default MFA is questions

####MFA Response
Submit the user's MFA response using

```Objective-C
- (void)submitMFAResponse: (NSString *)mfaResponse
              institution: (NSString *)institutionType
              accessToken: (NSString *)accessToken
    withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler;
```

userAccounts will either return another MFA response or the list of user accounts

####Download User Account Details And Transactions
```Objective-C
- (void)downloadAccountDetailsForAccessToken: (NSString *)accessToken
                                     account: (NSString *)accountID
                                     success: (void(^)(NSURLSessionDataTask *task, NSDictionary *accountDetails))success
                                     failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure;
```

```Objective-C
- (void) downloadTransactionsForAccessToken: (NSString *)accessToken
                                    pending: (BOOL) isPending
                                    account: (NSString *)accountID
                           sinceTransaction: (NSString *)transactionID
                                        gte: (NSDate *)fromDate
                                        lte: (NSDate *)toDate
                                    success: (void(^)(NSURLSessionDataTask *task, NSArray * transactions))handler
                                    failure: (void(^)(NSURLSessionDataTask *task, NSError *error))handler;
```
isPending, accountID, transactionID, fromDate, toDate are all optional fields.  Set to nil if not needed.  If accountID is not set, all transactions for the particular institution will be downloaded

####Plaid Entity Details
```Objective-C
- (void)downloadPlaidEntity: (NSString *)entityID
                    success: (void(^)(NSURLSessionDataTask *task, id plaidEntity))success
                    failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure;
```

     
