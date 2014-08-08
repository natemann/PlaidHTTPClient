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
