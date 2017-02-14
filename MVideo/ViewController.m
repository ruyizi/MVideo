//
//  ViewController.m
//  MVideo
//
//  Created by LiHongli on 16/6/18.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "NewPlayerViewController.h"
#import "KxMovieViewController.h"
#define FileNamePre @"videosList"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       *liveListTableView;
@property (nonatomic, strong) UIViewController  *playerController;
@property (nonatomic, strong) NSMutableArray    *dataSource;
@property (nonatomic, assign) NSInteger         tableNum;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataSource = [NSMutableArray array];
    [self.view addSubview:self.liveListTableView];
    
    [self addBackgroundMethod];
    [self operationStr];
    [self registerObserver];
    
    return;
    //    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 3 *NSEC_PER_SEC);
    //
    //    dispatch_after(time, dispatch_get_main_queue(), ^{
    //        NSURL *movieUrl = [NSURL URLWithString:@"http://123.108.164.110/etv1sb/pld10497/playlist.m3u8"]; //@"http://123.108.164.75/etv2sb/phd10062/playlist.m3u8"];
    //        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:movieUrl];
    //        [self presentMoviePlayerViewControllerAnimated:player];
    //    });
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)addBackgroundMethod{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)operationStr{
    for (NSInteger count = 0 ; count < NSIntegerMax; count ++) {
        NSString *fileName = [NSString stringWithFormat:@"%@%@",FileNamePre,@(count)];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.tableNum ++;
            NSMutableArray *itemArray = [NSMutableArray array];
            NSError *error = nil;
            NSString *videosText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            if (!error) {
                //            NSLog(@"%@", videosText);
                NSArray *videosArray = [videosText componentsSeparatedByString:@"\n"];
                for (NSString *subStr in videosArray) {
                    NSArray *subStrArray = [subStr componentsSeparatedByString:@","];
                    if(subStrArray.count == 2){
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [subStrArray firstObject] ?: @"",@"name",
                                              [subStrArray lastObject] ?: @"",@"liveUrl",
                                              nil];
                        [itemArray addObject:dict];
                    }else {
                        subStrArray = [subStr componentsSeparatedByString:@" "];
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [subStrArray firstObject] ?: @"",@"name",
                                              [subStrArray lastObject] ?: @"",@"liveUrl",
                                              nil];
                        [itemArray addObject:dict];
                    }
                    
                }
                [self.dataSource addObject:itemArray];
            }else {
                NSLog(@"error %@", error);
            }
        }else {
            NSLog(@"%@.txt不存在", fileName);
            break;
        }
    }
    [self.liveListTableView reloadData];
}

- (void)registerObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification{
    if ([self.playerController isKindOfClass:[NewPlayerViewController class]]) {
        [((NewPlayerViewController *)self.playerController).player play];
    }else {
        [((MPMoviePlayerViewController *)self.playerController).moviePlayer play];
    }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification{
    if ([self.playerController isKindOfClass:[NewPlayerViewController class]]) {
        [((NewPlayerViewController *)self.playerController).player pause];
    }else {
        [((MPMoviePlayerViewController *)self.playerController).moviePlayer pause];
    }
}

#pragma mark - Private Method

- (UITableView *)liveListTableView{
    if (_liveListTableView == nil) {
        _liveListTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _liveListTableView.delegate = self;
        _liveListTableView.dataSource = self;
        [_liveListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _liveListTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.tableNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = (self.dataSource.count > section) ? [self.dataSource[section] count] : 1;
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"%@%@",FileNamePre, @(section)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    
    if ((indexPath.section < self.tableNum) && (indexPath.row < [self.dataSource[indexPath.section] count])) {
        NSDictionary *dict =  self.dataSource[indexPath.section][indexPath.row];
        cell.textLabel.text = dict[@"name"];
        cell.detailTextLabel.text = [dict[@"liveUrl"] stringByReplacingOccurrencesOfString:@"[url]" withString:@""];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section < self.tableNum) && (indexPath.row < [self.dataSource[indexPath.section] count])) {
        NSDictionary *dict =  self.dataSource[indexPath.section][indexPath.row];
        NSLog(@"%@", dict);
        NSURL *movieUrl = [NSURL URLWithString:[dict[@"liveUrl"] stringByReplacingOccurrencesOfString:@"[url]" withString:@""]]; //@"http://123.108.164.75/etv2sb/phd10062/playlist.m3u8"];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
//            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:movieUrl];
//            AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
//            
//            NewPlayerViewController *playerVC = [[NewPlayerViewController alloc] init];
//            [playerVC setPlayer:avPlayer];
//            [avPlayer play];
//            self.playerController = playerVC;
//            [self presentViewController:playerVC animated:YES completion:nil];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"KxMovieParameterDisableDeinterlacing"] = @(YES);
            KxMovieViewController *vc = [KxMovieViewController
                                         movieViewControllerWithContentPath:movieUrl.absoluteString
                                         parameters:params];
            [self presentViewController:vc animated:YES completion:nil];
            
        }else {
            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:movieUrl];
            self.playerController = player;
            [self presentMoviePlayerViewControllerAnimated:player];
        }
    }
}

@end
