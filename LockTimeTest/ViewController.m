//
//  ViewController.m
//  LockTimeTest
//
//  Created by guodong on 2019/1/4.
//  Copyright © 2019 guodong. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>

#define ITERATIONS (1024*1024*32)

static unsigned long long disp=0, land=0;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testFuncPointer];
    test();
    [self testFuncPointer];
    // Do any additional setup after loading the view, typically from a nib.
}

-(int )testFuncPointer
{
    static int a;
    a++;
    return a;
}



int test()
{
    double then, now;
    unsigned int i, count;
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    OSSpinLock spinlock = OS_SPINLOCK_INIT;
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NSLock *lock = [NSLock new];
    then = CFAbsoluteTimeGetCurrent();
    for(i=0;i<ITERATIONS;++i)
    {
        [lock lock];
        [lock unlock];
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("NSLock: %f sec\n", now-then);
    
//    then = CFAbsoluteTimeGetCurrent();
//    IMP lockLock = [lock methodForSelector:@selector(lock)];
//    IMP unlockLock = [lock methodForSelector:@selector(unlock)];
//    for(i=0;i<ITERATIONS;++i)
//    {
//        lockLock(lock,@selector(lock));
//        unlockLock(lock,@selector(unlock));
//    }
//    now = CFAbsoluteTimeGetCurrent();
//    printf("NSLock+IMP Cache: %f sec\n", now-then);
    
    ViewController *a = [[ViewController alloc] init];
    
    IMP funcPointer = [a  methodForSelector:@selector(testFuncPointer)];
    
//    NSLog(@"funcPointer:%@",funcPointer);
    
    
    then = CFAbsoluteTimeGetCurrent();
    for(i=0;i<ITERATIONS;++i)
    {
        pthread_mutex_lock(&mutex);
        pthread_mutex_unlock(&mutex);
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("pthread_mutex: %f sec\n", now-then);
    
    then = CFAbsoluteTimeGetCurrent();
    for(i=0;i<ITERATIONS;++i)
    {
        OSSpinLockLock(&spinlock);
        OSSpinLockUnlock(&spinlock);
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("OSSpinlock: %f sec\n", now-then);
    
    id obj = [NSObject new];
    
    then = CFAbsoluteTimeGetCurrent();
    for(i=0;i<ITERATIONS;++i)
    {
        @synchronized(obj)
        {
        }
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("@synchronized: %f sec\n", now-then);
    
    [pool release];
    return 0;
}

@end
