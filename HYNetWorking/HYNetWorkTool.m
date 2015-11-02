//
//  HYNetWorkTool.m
//  05-封装post请求
//
//  Created by wanghy on 15/10/17.
//  Copyright © 2015年 wanghy. All rights reserved.
//

#import "HYNetWorkTool.h"
#define kBounary @"HYbounary"
@interface  HYNetWorkTool()

@end
@implementation HYNetWorkTool

#pragma mark -普通的POST网络请求

/**
 *  1.普通的POST网络请求，通过URL以及访问服务器的时候用的参数组成的字典访问网络
 *
 *  @param urlString    把请求发送到哪里去（请求的接口）
 *  @param paramater    包有参数的字典
 *  @param successBlock 成功之后的block
 *  @param failBlock    失败之后的block
 */
-(void)POSTWithTUrlString:(NSString*)urlString  paramater:(NSDictionary *)paramater successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock{
    
//    1.创建网络请求
    NSMutableURLRequest *HYrequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    HYrequest.HTTPMethod = @"POST";
//    创建一个可变字符串将字典中的数据拼接出来，去掉最后一个&
   __block NSMutableString *string = [NSMutableString string];
    [paramater enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        NSString *nameKey = key;
        NSString *nameVslue = obj;
    [string appendString:[NSString stringWithFormat:@"%@=%@&",nameKey,nameVslue]];
        
    }];

//    去掉字符串最后的&
    NSString *tempString = [string substringToIndex:(string.length-1)] ;
    
    [string setString:tempString];
    
    HYrequest.HTTPBody=[string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",string);
    
    [[[NSURLSession sharedSession]dataTaskWithRequest:HYrequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //      判断是否有数据
    
        if (data&&!error){
            NSAssert(successBlock, @"successBlock必须存在");
//            把数据传出去
            
//            id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            successBlock(data,response);
            
        }else{
            NSAssert(successBlock, @"failBlock必须存在");
//把错误穿传出去。
            failBlock(error);}

        }] resume];
   }


#pragma mark - 创建单例对象


// 获得单例对象(一次性代码)
// 只有通过这个方法获得的才是单例对象!
+(instancetype)sharedNetWorkTool{

    static id _netWork;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _netWork = [[HYNetWorkTool alloc]init];
        
    });

    return _netWork;
    }




#pragma mark - 上传单个文件

/**
 *  POST单个上传文件的请求
 *
 *  @param urlString    接口
 *  @param filePath     文件路径
 *  @param fileKey      服务器的key
 *  @param fileName     起个名
 *  @param paramater    参数字典
 *  @param successBlock 成功的block
 *  @param failBlock    失败的block
 */
- (void)POSTFileSWithUrlString:(NSString *)urlString filePath:(NSString *)filePath FileKey:(NSString *)fileKey FileName:(NSString *)fileName
                     paramater:(NSDictionary *)paramater
                  successBlock:(successBlock)successBlock
                     failBlock:(failBlock)failBlock;{
//    1.创建请求。
    NSMutableURLRequest *hyrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    hyrequest.HTTPMethod = @"POST";
    hyrequest.HTTPBody =[self getHttpBodyWithFilePath:filePath FileKey:fileKey FileName:fileName];

//    2.设置请求头,告诉服务器本次上传的文件信息
    NSString *contentType =
    [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kBounary];
    [hyrequest setValue:contentType forHTTPHeaderField:@"content-Type"];
    
    
    
//    发送请求
    [NSURLConnection sendAsynchronousRequest:hyrequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data&&!connectionError){
            
            NSAssert(successBlock, @"successBlock必须存在");
            //            把数据传出去
            successBlock(data,response);
            
        }else{
            NSAssert(failBlock, @"failBlock必须存在");
            //把错误传出去。
            failBlock(connectionError);}

    }];
}

 

#pragma mark -通过一个本地文件返回一个response,你可以用这个response来获得文件信息

/**
 *  通过一个本地文件返回一个response,你可以用这个response来获得文件信息
 *
 *  @return 返回一个response,你可以用这个response来获得文件信息
 */


- (NSURLResponse *)ReturnResponseWithfilePath:(NSString *)filePath {
    //    创建URL，因为是本地的文件一定要加file://
    NSString *hyUrl = [NSString stringWithFormat:@"file://%@", filePath];
    
    //    创建请求
    NSURLRequest *hyRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:hyUrl]];
    
    //  创建一个响应者
    NSURLResponse *hyResPonse = nil;
    //    发送请求(一定要是一个同步的请求)
    [NSURLConnection sendSynchronousRequest:hyRequest
                          returningResponse:&hyResPonse
                                      error:NULL];
    
    
    return hyResPonse;
}
    

#pragma mark -返回一个NSData类型的数据

/**
 *  上传文件时通过文件路径以及服务器的key上传单个文件，返回一个NSData类型的数据,你可以把它放在你的POST的请求的请求体中.
 *
 *  @param filepath   要上传的文件的路径
 *  @param serversKey 服务器提供的Key
 *  @param fileName   文件上传到服务器后的名称,可以为空
 *
 *  @return 返回一个NSData类型的数据,你可以把它放在你的POST的请求的请求体中.
 */
- (NSData *)getHttpBodyWithFilePath:(NSString *)filePath FileKey:(NSString *)fileKey FileName:(NSString *)fileName;{
    
    
        //    1.通过filepath获得response
        NSURLResponse *hyresponse = [self ReturnResponseWithfilePath:filePath];
        
        //    2.将需要上传的文件格式都转换成二进制数据,然后传给请求体!
        NSMutableData *data = [NSMutableData data];
        
        //    3.上传文件的上边界  \r\n :保证一定会换行,所有的服务器都认识! \n就是换行
        NSMutableString *headerStrM =
        [NSMutableString stringWithFormat:@"--%@\r\n", kBounary];
        
        // 参数: serversKey: 服务器接受文件参数的 key 值! 肯定是服务器人员告诉我们!
        // filename :文件上传到服务器之后保存的名称!可以自己指定!，不知定默认就是文件在本地的名字
        if (fileName == nil) {
            fileName = hyresponse.suggestedFilename;
        }
        [headerStrM
         appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",
         fileKey, fileName];
        
        // Content-Type:所上传文件的文件类型!
        [headerStrM appendFormat:@"Content-Type: %@\r\n\r\n", hyresponse.MIMEType];
        
        
        
        //    4 .上传的文件内容
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
        //    5. 上传文件的下边界
        NSMutableString *footerStrM =
        [NSMutableString stringWithFormat:@"\r\n--%@--", kBounary];
    
        //    6.将所有的内容添加到data中。
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:fileData];
        [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        return data;
    }






#pragma mark -多文件+文本信息上传


/**
 *  (多文件+文本信息)上传
 *
 *  @param urlString  接口
 *  @param fileDict   文件字典
 *  @param fileKey    服务器接受文件的key值
 *  @param paramaters 普通文本信息字典
 *  @param success    成功之后的回调
 *  @param fail       失败之后的回调
 *
 *  本方法默认处理服务器返回的JSON数据(自动解析JSON数据)
 *
 */
- (void)POSTFileAndMsgWithUrlString:(NSString *)urlString FileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramaters Success:(SuccessJson)success fail:(failBlock)fail{
    
    //    1.创建请求。
    NSMutableURLRequest *hyrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    hyrequest.HTTPMethod = @"POST";
//        2.获取
    hyrequest.HTTPBody =[self getHttpBodyWithFileDict:fileDict fileKey:fileKey paramater:paramaters];
    
    //    2.设置请求头,告诉服务器本次上传的文件信息
    NSString *contentType =
    [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kBounary];
    [hyrequest setValue:contentType forHTTPHeaderField:@"content-Type"];
    
    
    
    //    发送请求
    [NSURLConnection sendAsynchronousRequest:hyrequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data&&!connectionError){
            /**
             *  可以在这里就把data转换成oc的数据，也可以拿出去转换
             // JSON --> OC  解析JSON 数据
             id data = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
             */
            NSAssert(success, @"successBlock必须存在");
            //            把数据传出去
            success(data,response);
            
        }else{
            NSAssert(fail, @"failBlock必须存在");
            //把错误传出去。
            fail(connectionError);}
        
    }];

    



}




#pragma mark -多文件+文本信息上传请求体HTTPBODY

/**
 *  多文件上传+普通文本信息 格式封装
 *
 *  @param fileDict   文件字典: key(文件在服务器保存的名称)=value(文件路径)
 *  @param fileKey    服务器接受文件信息的key值
 *  @param paramaters 普通参数字典: key(服务器接受普通文本信息的key)=value(对应的文本信息)
 *
 *  @return 封装好的二进制数据(请求体)
 */
- (NSData *)getHttpBodyWithFileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramaters{

    
    NSMutableData *data = [NSMutableData data];
    
    // 遍历文件参数字典,设置文件的格式(会将所上传的文件数据格式封装起来)
    [fileDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // 取出每一条字典数据: fileName : 服务器保存的名称 , filePath: 文件路径
        NSString *fileName = key;
        NSString *filePath = obj;
        
        // 1.第一个文件的上边界
        NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBounary];
        
        // "userfile[]" 服务器接受文件的 key 值
        // "ARRAYJSON"  服务器保存的文件名
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",fileKey,fileName];
        
        NSURLResponse *response = [self ReturnResponseWithfilePath:filePath];
        
        // 文件类型
        [headerStrM appendFormat:@"Content-Type: %@\r\n\r\n",response.MIMEType];
        
        // 将文件的上边界添加到请求体中!
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 将文件内容添加到请求体中
        [data appendData:[NSData dataWithContentsOfFile:filePath]];
        
    }];
    
    // 遍历普通参数字典
    [paramaters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        // msgKey :服务器接受参数的key值 msgValue:上传的文本参数
        NSString *msgKey = key;
        NSString *msgValue = obj;
        
        // 普通文本信息上边界
        NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBounary];
        // "username": 服务器接受普通文本参数的key值.后端人员告诉我们的!
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",msgKey];
        
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 普通文本信息;
        [data appendData:[msgValue dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    // 3. 下边界 (只添加一次)
    NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--\r\n",kBounary];
    [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;




}

@end
