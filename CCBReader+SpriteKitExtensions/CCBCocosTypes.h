//
//  CCBCocosTypes.h
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

typedef NS_ENUM(unsigned char, CCPositionUnit)
{
    CCPositionUnitPoints,
    CCPositionUnitUIPoints,
    CCPositionUnitNormalized,
};

typedef NS_ENUM(unsigned char, CCSizeUnit)
{
    CCSizeUnitPoints,
    CCSizeUnitUIPoints,
    CCSizeUnitNormalized,
    CCSizeUnitInsetPoints,
    CCSizeUnitInsetUIPoints,
};

typedef NS_ENUM(unsigned char, CCPositionReferenceCorner)
{
    CCPositionReferenceCornerBottomLeft,
    CCPositionReferenceCornerTopLeft,
    CCPositionReferenceCornerTopRight,
    CCPositionReferenceCornerBottomRight,
};

typedef struct _CCPositionType
{
    CCPositionUnit xUnit;
    CCPositionUnit yUnit;
    CCPositionReferenceCorner corner;
} CCPositionType;

typedef struct _CCSizeType
{
    CCSizeUnit widthUnit;
    CCSizeUnit heightUnit;
} CCSizeType;

static inline CCPositionType CCPositionTypeMake(CCPositionUnit xUnit, CCPositionUnit yUnit, CCPositionReferenceCorner corner)
{
    CCPositionType pt;
    pt.xUnit = xUnit;
    pt.yUnit = yUnit;
    pt.corner = corner;
    return pt;
}

static inline CCSizeType CCSizeTypeMake(CCSizeUnit widthUnit, CCSizeUnit heightUnit)
{
    CCSizeType cst;
    cst.widthUnit = widthUnit;
    cst.heightUnit = heightUnit;
    return cst;
}

typedef NS_ENUM(char, CCScaleType) {
    CCScaleTypePoints,
    CCScaleTypeScaled,
};

typedef struct _ccBlendFunc
{
	unsigned int src;
	unsigned int dst;
} ccBlendFunc;

typedef NS_ENUM(unsigned char, CCPhysicsBodyType)
{
	CCPhysicsBodyTypeDynamic,
	CCPhysicsBodyTypeStatic,
};
