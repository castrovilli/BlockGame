//
//  BlockNode.h
//  BlockGame
//
//  Created by FT on 23/01/14.
//  Copyright (c) 2014 FT. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BlockNode : SKSpriteNode

@property (nonatomic,assign) NSUInteger column;
@property (nonatomic,assign) NSUInteger row;

-(BlockNode *) initWithRow:(NSUInteger) row
                 andColumn:(NSUInteger)column
                 withColor:(UIColor *)color
                   andSize:(CGSize)size;
@end
