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
#define ROWS            7
#define MIN_BLOCK_BUST  2

@interface MyScene(){
    NSArray *_colors;
}

- (NSArray *)getAllBlocks;
@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // The background Color for our scene
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        // Set the Gravity of our world
        self.physicsWorld.gravity = CGVectorMake(0,-8.f);
        
        // set up its physics body and set attributes
        SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(320, 40)];
        floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
        floor.physicsBody.dynamic = FALSE;
        floor.position = CGPointMake(160,20);
        
        // Add the floor to our scene
        [self addChild:floor];
        
        // Iterate through however many rows we have
        for (int row=0; row<ROWS; row++) {
            
            // and in each row iterate through number of columns we want
            for (int col = 0 ; col <COLUMNS; col++) {
                
                // generate the width and height for block
                CGFloat dimension = 320/COLUMNS;
                
                // Create list of color to apply to the block
                _colors = @[[UIColor greenColor],[UIColor blueColor],[UIColor yellowColor],[UIColor purpleColor]];
                
                // generate the random number to choose from the list of color
                NSUInteger colorIndex = arc4random() % _colors.count;
                
                // Generate the blocks with specified dimension, position and color
                BlockNode *block = [[BlockNode alloc] initWithRow:row
                                                        andColumn:col
                                                        withColor:[_colors objectAtIndex:colorIndex]
                                                          andSize:CGSizeMake(dimension, dimension)];
                
                [self.scene addChild:block];
                
            }
        }
        
        
    }
    return self;
}


// Determine if a node is directly on one side of the base node AND it is the same color
-(BOOL)inRange:(BlockNode *)testNode ofBlock:(BlockNode *)baseNode {
    
    // if the nodes are in the same row/column
    BOOL isRow = (baseNode.row == testNode.row);
    BOOL isCol = (baseNode.column == testNode.column);
    
    // if the nodes are one row/column apart
    BOOL oneOffCol = (baseNode.column+1 == testNode.column || baseNode.column-1 == testNode.column);
    BOOL oneOffRow = (baseNode.row+1 == testNode.row || baseNode.row-1 == testNode.row);
    
    // if the nodes are the same color
    BOOL sameColor = [baseNode.color isEqual:testNode.color];
    
    // Returns true when they are next to each other AND the same color
    return ( (isRow && oneOffCol) || (isCol && oneOffRow) ) && sameColor;
}


// a Recursive method used to find all similar blocks around a base block.
// the recursion allows us to reach beyond the current blocks's immediate neighblors to neighbors of neighbors, etc
-(NSMutableArray *)nodesToRemove:(NSMutableArray *)removeNodes aroundNode:(BlockNode *)baseNode{
    
    // Make sure our base node is being removed
    [removeNodes addObject:baseNode];
    
    // Go through all the blocks
    for (BlockNode *childNode in [self getAllBlocks]) {
        
        // if the node being tested is on one of the four sides off our base node
        // and it is the same color, it is in range and valid to be removed.
        if ([self inRange:childNode ofBlock:baseNode]) {
            
            // if we have not already checked if this block is being removed
            if (![removeNodes containsObject:childNode]) {
                
                // test the blocks around this one for possible removal
                removeNodes = [self nodesToRemove:removeNodes aroundNode:childNode];
            }
        }
    }
    return removeNodes;
}

// retrieve objects for every block within the scene
-(NSArray *)getAllBlocks{
    
    NSMutableArray *blocks = [NSMutableArray array];
    
    // iterate through all nodes
    for (SKNode *childNode in self.scene.children) {
        
        // see if it's of type 'BlockNode'
        if ([childNode isKindOfClass:[BlockNode class]]) {
            
            // add it to our tracking array
            [blocks addObject:childNode];
        }
    }
    return [NSArray arrayWithArray:blocks];
}

// a touch event occurred on the scene
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    /* Called when a touch begins */
    
    // Get a touch object
    UITouch *touch = [touches anyObject];
    
    // and the touch's Location
    CGPoint location = [touch locationInNode:self];
    
    // see which node was touched based on the Location of the touch
    SKNode *node = (SKNode *)[self nodeAtPoint:location];
    
    // if it was a block being touched
    if ([node isKindOfClass:[BlockNode class]]) {
        
        // cast it so we can access the attributes
        BlockNode *clickedblock = (BlockNode *)node;
        
        // Recursively retrieve all valid blocks around it
        NSMutableArray *blocksToRemove = [self nodesToRemove:[NSMutableArray array] aroundNode:clickedblock];
        
        // print a notice to the log
        NSLog(@"Selected Block: %d %d", clickedblock.row , clickedblock.column);
        
        // ensure that there are enough connected we need to delete
        if (blocksToRemove.count >= MIN_BLOCK_BUST) {
            for (BlockNode *deletedNode in blocksToRemove) {
                
                // remove it from the scene
                [deletedNode removeFromParent];
                
                // and decrement the 'row' variable for all blocks that sit above the one being removed
                for (BlockNode *testNode in [self getAllBlocks]) {
                    if (deletedNode.column == testNode.column && deletedNode.row < testNode.row) {
                        --testNode.row;
                    }
                }
            }
            
            // make sure our grid stays full even when blocks are removed by....
            
            // Initialize an array of 'maximum indexes for each column
            NSUInteger totalRows[COLUMNS];
            for (int i= 0; i< COLUMNS; i++) totalRows[i] = 0;
            
            // walk through our blocks
            for(BlockNode *node in [self getAllBlocks]){
                
                // Get the index of the highest row in each column
                if (node.row > totalRows[node.column]) {
                    totalRows[node.column] = node.row;
                }
            }
            
            // walk through each column
            for (int col=0; col<COLUMNS; col++) {
                
                // while there are not enough rows to fill the grid, create new blocks
                while (totalRows[col] < ROWS -1) {
                    
                    // generate the width and height for block
                    CGFloat dimension = 320/COLUMNS;
                    
                    // generate the random number to choose from the list of color
                    NSUInteger colorIndex = arc4random() % _colors.count;
                    
                    // Generate the blocks with specified dimension, position and color
                    BlockNode *block = [[BlockNode alloc] initWithRow:totalRows[col]+1 // the new row will be the top row in
                                                            andColumn:col
                                                            withColor:[_colors objectAtIndex:colorIndex]
                                                              andSize:CGSizeMake(dimension, dimension)];
                    
                    // add the block to our scene
                    [self.scene addChild:block];
                    
                    // increment the number of rows in this particular column
                    ++totalRows[col];

                }
            }
        }
        
    }
    
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
