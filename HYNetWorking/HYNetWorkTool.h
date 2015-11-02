//
//  HYNetWorkTool.h
//  05-封装post请求
//
//  Created by wanghy on 15/10/17.
//  Copyright © 2015年 wanghy. All rights reserved.
//

#import <Foundation/Foundation.h>
//搞两个block：网络请求成功的block以及失败的block
typedef void (^successBlock)(NSData *data, NSURLResponse *response);
typedef void (^failBlock)(NSError *error);
typedef void (^SuccessJson)(id responseObject, NSURLResponse *response);

@interface HYNetWorkTool : NSObject

/**
 *  1.普通的POST网络请求，通过URL以及访问服务器的时候用的参数组成的字典访问网络
 *
 *  @param urlString    把请求发送到哪里去（请求的接口）
 *  @param paramater    包有参数的字典
 *  @param successBlock 成功之后的block
 *  @param failBlock    失败之后的block
 */
- (void)POSTWithTUrlString:(NSString *)urlString
                 paramater:(NSDictionary *)paramater
              successBlock:(successBlock)successBlock
                 failBlock:(failBlock)failBlock;

/**
 *  2.上传文件的请求
 *
 *  @param urlString    接口
 *  @param filePath     文件路径
 *  @param fileKey      服务器的key
 *  @param fileName     起个名
 *  @param paramater    参数字典
 *  @param successBlock 成功的block
 *  @param failBlock    失败的block
 */
- (void)POSTFileSWithUrlString:(NSString *)urlString
                      filePath:(NSString *)filePath
                       FileKey:(NSString *)fileKey
                      FileName:(NSString *)fileName
                     paramater:(NSDictionary *)paramater
                  successBlock:(successBlock)successBlock
                     failBlock:(failBlock)failBlock;

/**
 *  3.上传文件时的网络请求。通过文件路径以及服务器的key上传单个文件，返回一个NSData类型的数据,你可以把它放在你的POST的请求的请求体中.
 *
 *  @param filepath   要上传的文件的路径
 *  @param serversKey 服务器提供的Key
 *  @param fileName   文件上传到服务器后的名称,可以为空
 *
 *  @return 返回一个NSData类型的数据,你可以把它放在你的POST的请求的请求体中.
 */
- (NSData *)getHttpBodyWithFilePath:(NSString *)filePath
                            FileKey:(NSString *)fileKey
                           FileName:(NSString *)fileName;

/**
 *  4.实例化单利网络请求的方法
 *
 *  @return 返回一个单利
 */
+ (instancetype)sharedNetWorkTool;

/**
 *  通过一个本地文件返回一个response,你可以用这个response来获得文件信息
 *
 *  @return 返回一个response,你可以用这个response来获得文件信息
 */
- (NSURLResponse *)ReturnResponseWithfilePath:filepath;

#pragma mark -多文件上传
/**
 *     多文件上传
 *
 *  @param urlString  接口
 *  @param fileDict   文件字典
 *  @param fileKey    服务器的key
 *  @param paramaters 普通参数字典
 *  @param success    成功后的回调
 *  @param fail       失败的回调
 */
- (void)POSTFileAndMsgWithUrlString:(NSString *)urlString
                           FileDict:(NSDictionary *)fileDict
                            fileKey:(NSString *)fileKey
                          paramater:(NSDictionary *)paramaters
                            Success:(SuccessJson)success
                               fail:(failBlock)fail;

#pragma mark -多文件+文本信息上传请求体

/**
 *  多文件上传+普通文本信息 格式封装
 *
 *  @param fileDict   文件字典: key(文件在服务器保存的名称)=value(文件路径)
 *  @param fileKey    服务器接受文件信息的key值
 *  @param paramaters 普通参数字典:
 *key(服务器接受普通文本信息的key)=value(对应的文本信息)
 *
 *  @return 封装好的二进制数据(请求体)
 */
- (NSData *)getHttpBodyWithFileDict:(NSDictionary *)fileDict
                            fileKey:(NSString *)fileKey
                          paramater:(NSDictionary *)paramaters;
@end
