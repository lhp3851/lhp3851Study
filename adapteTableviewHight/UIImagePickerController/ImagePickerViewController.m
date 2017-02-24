//
//  ImagePickerViewController.m
//  AVFoundatonStudy
//
//  Created by lhp3851 on 16/7/26.
//  Copyright © 2016年 jerry. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "LXButton.h"

@interface ImagePickerViewController (){
    CGFloat currentLight;
}
@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImageView *photo;//照片展示视图
@property (strong ,nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频
@end

@implementation ImagePickerViewController


-(UIImageView *)photo{
    if (!_photo) {
        _photo=[[UIImageView alloc]init];
        [_photo setFrame:CGRectMake(0,0, kSCREENWIDTH-100, kSCREENHEIGHT/2)];
        _photo.center=self.view.center;
        _photo.hidden=YES;
        [self.view addSubview:_photo];
    }
    return _photo;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[UIScreen mainScreen] setBrightness: currentLight];
//    CGFloat Light = [[UIScreen mainScreen] brightness];
//    NSLog(@"Light:%f",Light);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    //通过这里设置时拍照还是录制视频
    _isVideo=NO;

}

-(void)setScreenBrightness{
    currentLight = [[UIScreen mainScreen] brightness];
    NSLog(@"currentLight:%f",currentLight);
    [[UIScreen mainScreen] setBrightness: 1.0f];
    CGFloat Light = [[UIScreen mainScreen] brightness];
    NSLog(@"Light:%f",Light);
}

-(void)setUpUI{
    self.view.backgroundColor=[UIColor whiteColor];
    LXButton *audioEffectButton=[LXButton setTitle:@"ImagePicker" normaTitleColor:[UIColor blueColor] heilightTitleColor:[UIColor whiteColor] prohibitTitleColor:[UIColor grayColor] normaBackGroundColor:[UIColor orangeColor] heilightBackGroundColor:[UIColor lightGrayColor] prohibitBackGroundColor:[UIColor grayColor] buttonType:UIButtonTypeCustom];
    [audioEffectButton setFrame:CGRectMake(kHMARGIN, kSTATUS_BAR_HEIGHT+kNAVIGATION_BAR_HEIGHT+10, 120, 30)];
    [audioEffectButton addTarget:self action:@selector(takePictureClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioEffectButton];
}

#pragma mark - UI事件
//点击拍照按钮
- (void)takePictureClick:(UIButton *)sender {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        NSLog(@"无权限");
    }
    else{
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果时拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        [self.photo setImage:image];//显示照片
        [self.photo setHidden:NO];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有方法
-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker=[[UIImagePickerController alloc]init];
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
        _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
        if (self.isVideo) {
            _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
            
        }else{
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing=YES;//允许编辑
        _imagePicker.delegate=self;//设置代理，检测操作
    }
    return _imagePicker;
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        [self.photo setHidden:NO];
        playerLayer.frame=self.photo.frame;
        [self.photo.layer addSublayer:playerLayer];
        [_player play];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
