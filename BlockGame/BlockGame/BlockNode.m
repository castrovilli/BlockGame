//
//  BlockNode.m
//  BlockGame
//
//  Created by FT on 23/01/14.
//  Copyright (c) 2014 FT. All rights reserved.
//

#import "BlockNode.h"

@implementation BlockNode

-(BlockNode *) initWithRow:(NSUInteger) row
                 andColumn:(NSUInteger)column
                 withColor:(UIColor *)color
                   andSize:(CGSize)size{
    
    self = [super initWithColor:color size:size];
    
    if(self){
        _row = row;
        _column = column;
        
        // create a Physics body for this block and set attributes for it
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(size.width-2, size.height-2)];
        
        // set Restitution for physics body
        self.physicsBody.restitution  = 0.0f;
        
        // Set Rotation to False to protect block from falling sideways
        self.physicsBody.allowsRotation = FALSE;
        
        // postion the block within the scene
        // generate the xPosition & yPosition base on each row and column they are in
        CGFloat xPosition = (size.width/2) + _column * size.width;
        CGFloat yPosition = 480 + ((size.height/2)+ _row * size.height);
        
        // postion the block within the scene
        self.position = CGPointMake(xPosition, yPosition);
    }
    return self;
}

@end
