//
//  RequestConfigurationOperation.m
//  Conferences
//
//  Created by Egor Tolstoy on 02/09/15.
//  Copyright © 2015 Rambler&Co. All rights reserved.
//

#import "RequestConfigurationOperation.h"

#import "RCFRequestConfigurator.h"
#import "RCFRequestDataModel.h"

#import <CocoalumberJack/CocoaLumberjack.h>

static const int ddLogLevel = DDLogLevelVerbose;

@interface RequestConfigurationOperation ()

@property (strong, nonatomic) id<RCFRequestConfigurator> requestConfigurator;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSString *serviceName;
@property (strong, nonatomic) NSArray *urlParameters;

@end

@implementation RequestConfigurationOperation

@synthesize delegate = _delegate;
@synthesize input = _input;
@synthesize output = _output;

#pragma mark - Initialization

- (instancetype)initWithRequestConfigurator:(id<RCFRequestConfigurator>)configurator
                                     method:(NSString *)method
                                serviceName:(NSString *)serviceName
                              urlParameters:(NSArray *)urlParameters {
    self = [super init];
    if (self) {
        _requestConfigurator = configurator;
        _method = method;
        _serviceName = serviceName;
        _urlParameters = urlParameters;
    }
    return self;
}

+ (instancetype)operationWithRequestConfigurator:(id<RCFRequestConfigurator>)configurator
                                          method:(NSString *)method
                                     serviceName:(NSString *)serviceName
                                   urlParameters:(NSArray *)urlParameters {
    return [[[self class] alloc] initWithRequestConfigurator:configurator
                                                      method:method
                                                 serviceName:serviceName
                                               urlParameters:urlParameters];
}

#pragma mark - Operation execution

- (void)main {
    DDLogVerbose(@"The operation %@ is started", NSStringFromClass([self class]));
    RCFRequestDataModel *inputData = [self.input obtainInputDataWithTypeValidationBlock:^BOOL(id data) {
        if ([data isKindOfClass:[RCFRequestDataModel class]] || data == nil) {
            DDLogVerbose(@"The input data for the operation %@ has passed the validation", NSStringFromClass([self class]));
            return YES;
        }
        DDLogVerbose(@"The input data for the operation %@ hasn't passed the validation. The input data type is: %@",
                     NSStringFromClass([self class]),
                     NSStringFromClass([data class]));
        return NO;
    }];
    
    NSURLRequest *request = [self.requestConfigurator requestWithMethod:self.method
                                                            serviceName:self.serviceName
                                                          urlParameters:self.urlParameters
                                                       requestDataModel:inputData];
    
    DDLogVerbose(@"Successfully created a request: %@", request);
    [self completeOperationWithData:request error:nil];
}

- (void)completeOperationWithData:(id)data error:(NSError *)error {
    if (data) {
        [self.output didCompleteChainableOperationWithOutputData:data];
        DDLogVerbose(@"The operation %@ output data has been passed to the buffer", NSStringFromClass([self class]));
    }
    
    [self.delegate didCompleteChainableOperationWithError:error];
    DDLogVerbose(@"The operation %@ is over", NSStringFromClass([self class]));
    [self complete];
}

#pragma mark - Debug

- (NSString *)debugDescription {
    NSArray *additionalDebugInfo = @[
                                     [NSString stringWithFormat:@"Works with configurator: %@\n",
                                      [self.requestConfigurator debugDescription]]
                                     ];
    return [OperationDebugDescriptionFormatter debugDescriptionForOperation:self
                                                         withAdditionalInfo:additionalDebugInfo];
}

@end
