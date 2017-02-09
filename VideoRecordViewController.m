//
//  VideoRecordViewController.m
//  videoRecordingDemo
//
//  Created by ule_zhangfanglin on 2017/2/7.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "VideoRecordViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <Photos/Photos.h>  // 代替
@interface VideoRecordViewController ()<AVCaptureFileOutputRecordingDelegate>
{
      AVCaptureMovieFileOutput * output;
}
@end

@implementation VideoRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建视频
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //2.初始化一个摄像头输入设备(first是后置摄像头，last是前置摄像头)
    AVCaptureDeviceInput *inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:NULL];
    //创建麦克风设备
    AVCaptureDevice  * deviceAudio=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput * inputAudio=[AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:NULL];
    
    //初始化视频文件输出
    AVCaptureMovieFileOutput * m_output=[[AVCaptureMovieFileOutput  alloc] init];
    output=m_output;
    //
    
    //初始化一个会话
    AVCaptureSession * session =[[AVCaptureSession alloc] init];
      [session setSessionPreset:AVCaptureSessionPresetMedium];
    //将输出设备添加到会话
    if ([session canAddInput:inputVideo]) {
        [session addInput:inputVideo];
    }
    if([session canAddInput:inputAudio])
    {
        [session addInput:inputAudio];
    }
    if ([session canAddOutput:m_output]) {
        [session addOutput:m_output];
    }
    //添加一个视频预览图层   设置大小，添加到控制器view 的图层上
    AVCaptureVideoPreviewLayer   * preLayer=[AVCaptureVideoPreviewLayer  layerWithSession:session];
    preLayer.frame=self.view.bounds;
    [self.view.layer addSublayer:preLayer];
    UIButton * button_startButton=[[UIButton alloc] initWithFrame:CGRectMake(200,100 ,50 , 50)];
    [button_startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button_startButton setTitle:@"录制" forState:UIControlStateNormal];
    [button_startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_startButton];
    
    //开始会话
    [session startRunning];
    
}
-(void)startAction:(UIButton *)sender
{
    if ([output isRecording]) {
        [output stopRecording];
        [sender setTitle:@"录制" forState:UIControlStateNormal];
        return;
    }
    [sender setTitle:@"停止" forState:UIControlStateNormal];
    NSString * path=
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myvideo.mov"];
    
    NSURL * url=[NSURL fileURLWithPath:path];
    [output startRecordingToOutputFileURL:url recordingDelegate:self];
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"录制完成");
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error

{
    __block NSString *assetLocalIdentifier = nil;
    //相册集合
    PHFetchResult * collrctionReault=[PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    //集合遍历
    [collrctionReault enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection * assetCollection=obj;
        if ([assetCollection.localizedTitle isEqualToString:@"a"]) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *assetRequst=[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                //请求编辑相册
                PHAssetCollectionChangeRequest * collectionRequst=[PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //asset创建一个占位符
                PHObjectPlaceholder * placeholder=[assetRequst placeholderForCreatedAsset];
                [collectionRequst addAssets:@[placeholder]]; //添加视频
                assetLocalIdentifier =placeholder.localIdentifier;
                
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success == NO) {
                    NSLog(@"保存成功");
                }

            }];
        }
    }];
    
    
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
