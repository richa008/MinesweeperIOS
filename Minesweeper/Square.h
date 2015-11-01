//
//  Square.h
//  Minesweeper
//
//  Created by Deshmukh,Richa on 10/26/15.
//  Copyright (c) 2015 Richa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SquareStatus)
{
    ClosedSquare,
    OpenedSquare,
    FlaggedSquare
};

@interface Square : NSObject

@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger column;
@property (nonatomic) NSInteger value;

@property (nonatomic) BOOL minePresent;
@property (nonatomic) SquareStatus squareStatus;

@end
