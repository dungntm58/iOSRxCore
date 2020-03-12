//
//  Util+Internal.h
//  RxCoreBase
//
//  Created by Robert on 1/27/20.
//

#ifndef Util_Internal_h
#define Util_Internal_h

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (void)swizzling: (Class)swizzedClass originalSelector: (SEL)originalSelector swizzledSelector: (SEL)swizzledSelector;

@end

#endif /* Util_Internal_h */
