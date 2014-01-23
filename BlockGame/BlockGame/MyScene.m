//
//  MyScene.m
//  BlockGame
//
//  Created by FT on 22/01/14.
//  Copyright (c) 2014 FT. All rights reserved.
//

#import "MyScene.h"
#import "BlockNode.h"

#define COLUMNS         6
#define ROWS            6

@implementation MyScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // The background Color for our scene
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        // Set the Gravity of our world
        self.physicsWorld.gravity = CGVectorMake(0,-1.f);
        
        // set up its physics body and set attributes
        SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(320, 40)];
        floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
        floor.physicsBody.dynamic = FALSE;
        floor.position = CGPointMake(160,20);
        
        // add the floor to our scene
        [self addChild:floor];
        
        // Rotate through however many rows we have
        for (int row=0; row<ROWS; row++) {
            
            // and in each row iterate through number of columns we want
            for (int col = 0 ; col <COLUMNS; col++) {
                
                // generate the width and height for block
                CGFloat dimension = 320/COLUMNS;
                
                // Create list of color to apply to the block
                NSArray *colors = @[[UIColor greenColor],[UIColor blueColor],[UIColor yellowColor]];
                
                // generate the random number to choose from the list of color
                NSUInteger colorIndex = arc4random() % colors.count;
                
                // Generate the blocks with specified dimension, position and color
                BlockNode *block = [[BlockNode alloc] initWithRow:row
                                                        andColumn:col
                                                        withColor:[colors objectAtIndex:colorIndex]
                                                          andSize:CGSizeMake(dimension, dimension)];
                
                [self.scene addChild:block];
                
            }
        }
        
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // go through each blocks our scene
    for (SKNode* node in self.scene.children){
        
        // and normalize the position so it falls exactly on a pixel
        node.position = CGPointMake(round(node.position.x), (node.position.y));
    }
}

@end
