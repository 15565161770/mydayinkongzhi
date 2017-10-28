//
//  ViewController.m
//  Print_Demo
//
//  Created by Model on 2017/10/28.
//  Copyright © 2017年 Model. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()<UIPrintInteractionControllerDelegate>
@property (nonatomic, strong) UIPrintInteractionController * printController;

@property (nonatomic, strong) UIPrintInfo * printInfo;

@property (nonatomic, strong) NSData * printData;

@property (nonatomic, assign) BOOL isPrinting;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    button.backgroundColor = [UIColor redColor];
    
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

// 打印方法
- (void)buttonClick:(id)sender {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"456.png" ofType:@""];
    // 判断文件是否存在
    if (!path) {
        [self releasePirntData];
        return;
    }
    
    self.printData = [NSData dataWithContentsOfFile:path];

    self.printController = [UIPrintInteractionController sharedPrintController];

    /*
     AirPrint可以直接打印一些内容。 这些内容是 NSData, NSURL, UIImage, and ALAsset 类的实例， 但是这些实例的内容， 或者引用的类型（NSURL）必须是 image 或者pdf.
     对于 image来说， NSData, NSURL, UIImage, and ALAsset 类型都可以的。 对于PDF， 只能使用 NSData, NSURL。 然后需要将这些数据实例直接赋值 给 UIPrintInteractionController实例的 printingItem 或者 printingItems 属性。
     */

    if (self.printController && [UIPrintInteractionController canPrintData: self.printData]) {
        self.printController.delegate = self;
        self.printInfo = [UIPrintInfo printInfo];
        /*
         General（默认）：文本和图形混合类型；允许双面打印。
         Grayscale：如果你的内容只包括黑色文本，那么该类型比 .General 更好。
         Photo：彩色或黑白图像；禁用双面打印，更适用于图像媒体的纸张类型。
         PhotoGrayscale：对于仅灰度的图像，根据打印机的不同，该类型可能比 .Photo 更好。
         */
        self.printInfo.outputType = UIPrintInfoOutputGeneral;
        self.printInfo.jobName = @"docName"; // 自动获取的文件name
        /*
         None、.ShortEdge 或 .LongEd​​ge。short- 和 long- 的边界设置指示如何装订双面页面，而 .None 不支持双面打印（这里不是 UI 切换为双面打印，令人困惑）
         */
        self.printInfo.duplex = UIPrintInfoDuplexLongEdge;
        self.printController.printInfo = self.printInfo;
        self.printController.showsPageRange = YES;
        self.printController.printingItem = self.printData;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            NSLog(@"---------%@", error.description);
//            if (!completed || error) {
//                NSLog(@"Printing could not complete because of error: %@", error);
//                completion(error);
//            }
        };
        [self.printController presentAnimated:YES completionHandler:completionHandler];
        
    } else {
        [self releasePirntData];
        NSError * error = [[NSError alloc] initWithDomain: @"print data error" code: -1 userInfo:nil];
//        completion(error);
    }
}


#pragma mark -- 打印代理
- (void)printWebDoucment {
    self.printController = nil;
    self.printInfo = nil;
    
    self.printController = [UIPrintInteractionController sharedPrintController];
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed || error){
            NSLog(@"FAILED! due to error in domain %@ with error code %ld",
                  error.domain, (long)error.code);
        }
    };
    self.printInfo = [UIPrintInfo printInfo];
    self.printInfo.outputType = UIPrintInfoOutputGeneral;
    self.printInfo.jobName = @"webview";
    self.printInfo.duplex = UIPrintInfoDuplexLongEdge;
    self.printController.printInfo = self.printInfo;
    self.printController.showsPageRange = YES;
    UIWebView * webview = [[UIWebView alloc] init];
    NSURLRequest * requset = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString: @"https://www.baidu.com"]];        // 或加载本地文件
    [webview loadRequest: requset];
    UIViewPrintFormatter *viewFormatter = [webview viewPrintFormatter];
    viewFormatter.startPage = 0;
    
    self.printController.printFormatter = viewFormatter;
    
    [self.printController presentAnimated:YES completionHandler:completionHandler];
}

- (void)printHtmlDoucment {
    self.printController = nil;
    self.printInfo = nil;
    
    self.printController = [UIPrintInteractionController sharedPrintController];
    self.printController.delegate = self;
    
    self.printInfo = [UIPrintInfo printInfo];
    self.printInfo.outputType = UIPrintInfoOutputGeneral;
    self.printInfo.jobName = @"html";
    self.printController.printInfo = self.printInfo;
    
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc]
                                                 initWithMarkupText: @""];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    self.printController.printFormatter = htmlFormatter;
    self.printController.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed || error) {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    [self.printController presentAnimated:YES completionHandler:completionHandler];
}

- (void)releasePirntData {
    self.printData = nil;
    self.printInfo = nil;
    self.printController = nil;
//    self.printDoc = nil;
//    self.printParentController = nil;
}

#pragma mark -- Print Delegate

- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController {
    return self.printParentController;
}

- (void)printInteractionControllerWillPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    
}

- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    [self releasePirntData];
}

- (void)printInteractionControllerWillStartJob:(UIPrintInteractionController *)printInteractionController {
    
}

- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController {
    [self releasePirntData];
}


@end
