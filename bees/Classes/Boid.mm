
/**
 * Boid.m
 * This is an Objective-C/Cocos2D port of an AS3 Boid behavior class 
 * (original class shown here http://blog.soulwire.co.uk/laboratory/flash/as3-flocking-steering-behaviors)
 * 
 * You can modify this script in any way you choose
 * and use it for any purpose providing this header 
 * remains intact and the original author is credited
 *  
 * Created by Mario Gonzalez on 2/13/10.
 * Copyright 2010 http://onedayitwillmake.com. All rights reserved.
 **/ 
/**		
 * 
 *	Boid v1.00
 *	15/10/2008 11:31
 * 
 *	© JUSTIN WINDLE | soulwire ltd
 *	http://blog.soulwire.co.uk
 *	f
 
 *	Released under the Creative Commons 3.0 license
 *	@see http://creativecommons.org/licenses/by/3.0/
 *	
 *	You can modify this script in any way you choose 
 *	and use it for any purpose providing this header 
 *	remains intact and the original author is credited
 * 
 **/

#import "Boid.h"

#define rad2Deg 57.2957795

#define leftEdge 10.0f
#define bottomEdge 32.0f
#define topEdge 310.0f
#define rightEdge 465.0f

#define IGNORE 1.0f

@implementation Boid
@synthesize collisionType = _collistionType;
@synthesize maxForce=_maxForce, maxSpeed=_maxSpeed;
@synthesize edgeBehavior=_edgeBehavior;
@synthesize doRotation=_doRotation;
@synthesize acceleration = _acceleration;
@synthesize hasDisease = _hasDisease;
@synthesize illnessTime = _illnessTime;
@synthesize damage = _damage;
@synthesize isCombatMode = _isCombatMode;
@synthesize startMaxForce = _startMaxForce;
@synthesize startMaxSpeed = _startMaxSpeed;
@synthesize scaledBoundingBox = _scaledBoundingBox;
@synthesize leftEdgePosition = _leftEdgePosition;
@synthesize specy = _specy;
@synthesize isDead = _isDead;

#pragma mark Initialization
- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		self.maxForce = 0.0f;
		self.maxSpeed = 0.0f;
		self.edgeBehavior = EDGE_NONE;
		self.doRotation = false;
		self.specy = BEE;
		_wanderTheta = 0.0f;
		
		[self resetVectorsToZero];
		_acceleration = ccp(CCRANDOM_0_1() * 0.5, CCRANDOM_0_1() * 0.5);
		// Debug
		//		[self setSpeedMax: 2.5f andSteeringForceMax: 0.5f];
		//		[self setWanderingRadius:8.0f lookAheadDistance:30.0f andMaxTurningAngle:0.25f];
	}
	return self;
}


-(void) makeSick:(float)speed withForce:(float)force{
	if (_isSick == NO){
		[self setMaxForce:_startMaxForce * force];
		[self setMaxSpeed:_startMaxSpeed * speed];
		_isSick = YES;
	}
}

-(void) cure{
	_isSick = NO;
	[self setNormalSpeed];
}

-(void) boost:(float)speed withForce:(float)force{
	[self setMaxForce:_startMaxForce * force];
	[self setMaxSpeed:_startMaxSpeed * speed];
}

-(void) setNormalSpeed{
	[self setMaxForce: _startMaxForce];
	[self setMaxSpeed: _startMaxSpeed];
}

-(void) clearEffects{
	[self setNormalSpeed];
	_isSick = NO;
	[self setMaxForce:_startMaxForce];
	[self setMaxSpeed:_startMaxSpeed];
	_illnessTime = 0;
	_oldInternalPosition = _internalPosition;
	[self resetVectorsToZero];
}

-(void) setSpeedMax:(float)speed andSteeringForceMax:(float)force
{
	self.maxSpeed = speed;
	self.maxForce = force;
	if (_startMaxForce == 0){
		_startMaxForce = force;
	}
	if (_startMaxSpeed == 0){
		_startMaxSpeed = speed;
	}
}

-(void) setSpeedMax:(float)speed withRandomRangeOf:(float)speedRange andSteeringForceMax:(float)force withRandomRangeOf:(float)forceRange
{ 
    [self
     setSpeedMax:randRange(speed - speedRange, speed + speedRange) 
     andSteeringForceMax:randRange(force - forceRange, force + forceRange)];
}

-(void) setWanderingRadius:(float)radius lookAheadDistance:(float)distance andMaxTurningAngle:(float)turningAngle
{
	_wanderMaxTurnCircleRadius = radius;
	_wanderLookAheadDistance = distance;
	_wanderTurningRadius = turningAngle;
}

-(void) resetVectorsToZero
{
	_velocity = CGPointZero;
	_internalPosition = CGPointZero;
	_oldInternalPosition = CGPointZero;
	_acceleration = CGPointZero;
	_steeringForce = CGPointZero;
}

#pragma mark Update
-(void) update
{	
	if (_illnessTime < 0){
		_illnessTime = 0;
	}
	if (_hasDisease && _illnessTime <= 0){
		[self cure];
	}
	_oldInternalPosition.x = _internalPosition.x;
	_oldInternalPosition.y = _internalPosition.y;
	_velocity = ccpAdd(_velocity,ccp(_acceleration.x, _acceleration.y));
	
	// Cap the velocity
	float velocityLengthSquared = ccpLengthSQ(_velocity);
	if(velocityLengthSquared > _maxSpeedSQ)
	{
		_velocity = normalize(_velocity);
		_velocity = ccpMult(_velocity, _maxSpeed);
	}
	
	// Move the boid and reset the acceleration
	_internalPosition = ccpAdd(_internalPosition, _velocity);
	
	if (_doRotation) {
		self.rotation = atan2f(_oldInternalPosition.y-_internalPosition.y, _oldInternalPosition.x-_internalPosition.x ) * -rad2Deg;
	}
	
	_acceleration = CGPointZero;	
	
	[self handleBorder];
	
	self.position = ccp(_internalPosition.x, _internalPosition.y);
}




-(void) update:(ccTime)dt
{	
	if (_illnessTime < 0){
		_illnessTime = 0;
	}
	if (_hasDisease && _illnessTime <= 0){
		[self cure];
	}
	_oldInternalPosition.x = _internalPosition.x;
	_oldInternalPosition.y = _internalPosition.y;
	_velocity = ccpAdd(_velocity,ccp(_acceleration.x , _acceleration.y ));
	
	// Cap the velocity
	float velocityLengthSquared = ccpLengthSQ(_velocity);
	if(velocityLengthSquared > _maxSpeedSQ)
	{
		_velocity = normalize(_velocity);
		_velocity = ccpMult(_velocity, _maxSpeed);
	}
	
	// Move the boid and reset the acceleration
	_internalPosition = ccpAdd(_internalPosition, ccp(_velocity.x  * dt * 60, _velocity.y * dt * 60));
	
	if (_doRotation) {
		self.rotation = atan2f(_oldInternalPosition.y-_internalPosition.y, _oldInternalPosition.x-_internalPosition.x ) * -rad2Deg;
	}
	
	_acceleration = CGPointZero;	
	
	[self handleBorder];
	
	self.position = ccp(_internalPosition.x, _internalPosition.y);
}


-(void) handleBorder
{
	if(_edgeBehavior == EDGE_WRAP)
	{	
		if (_internalPosition.y < bottomEdge) {//[self setPos:ccp(_internalPosition.x, topEdge)];
			_internalPosition.y = bottomEdge;
			if (_velocity.y < 0){
				_velocity.y *= -1.0f;
			}
		}
		if (_internalPosition.y > topEdge) {//[self setPos:ccp(_internalPosition.x, topEdge)];
			_internalPosition.y = topEdge;
			if (_velocity.y > 0){
				_velocity.y *= -1.0f;
			}
		}
		//else if (_internalPosition.y > topEdge) [self setPos:ccp(_internalPosition.x, bottomEdge)];
		if(_internalPosition.x < _leftEdgePosition.x) {
			_internalPosition.x = _leftEdgePosition.x;
			if (_velocity.x < 0){
				_velocity.x *= -1.0f;
			}
		}
	} 
}

#pragma mark Movement
-(CGPoint) steer:(CGPoint)target easeAsApproaching:(BOOL)ease withEaseDistance:(float)easeDistance
{
	_steeringForce = ccp(target.x, target.y);
	_steeringForce = ccpSub(_steeringForce, _internalPosition);
	
	float distanceSquared = ccpLengthSQ(_steeringForce);
	float easeDistanceSquared = easeDistance * easeDistance;
	
	if(distanceSquared > FLT_EPSILON)
	{
		// Slow down or not
		if(ease && distanceSquared < easeDistanceSquared) {
			float distance = sqrtf(distanceSquared);
			_steeringForce = ccpMult(_steeringForce, _maxSpeed * (distance/easeDistance) );
		} else {
			_steeringForce = ccpMult(_steeringForce, _maxSpeed);
		}
		
		// Slow down
		_steeringForce = ccpSub(_steeringForce, _velocity);
		
		// Cap
		float steeringForceLengthSquared = ccpLengthSQ(_steeringForce);
		if(steeringForceLengthSquared > _maxForceSQ)
		{
			_steeringForce = normalize(_steeringForce);
			_steeringForce = ccpMult(_steeringForce, _maxForce);
		}
	}
	
	return _steeringForce;
}

-(void) brake:(float)brakingForce
{
	_velocity = ccpMult(_velocity, 1.0f - brakingForce);
}

#pragma mark Behaviors
-(void) seek:(CGPoint)target usingMultiplier:(float)multiplier
{
	_steeringForce = [self steer:target easeAsApproaching:NO withEaseDistance:IGNORE];
	
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}

-(void) seek:(CGPoint)target withinRange:(float)range usingMultiplier:(float)multiplier
{
	float rangeSQ = range * range;
	float distanceSQ = getDistanceSquared(_internalPosition, target);
	
	// we're as close as we want to get 
	if(distanceSQ < rangeSQ) {
		return;
	}
	
	_steeringForce = [self steer:target easeAsApproaching:NO withEaseDistance:IGNORE];
	
	// Pass in zero to ignore mutliplier, is this faster than just doing the operation? I dunno
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}

-(void) arrive:(CGPoint)target withEaseDistance:(float)easeDistance usingMultiplier:(float)multiplier
{
	_steeringForce = [self steer:target easeAsApproaching:YES withEaseDistance:easeDistance];
	
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}



-(void) flee:(CGPoint)target panicAtDistance:(float)panicDistance usingMultiplier:(float)multiplier
{
	float panicDistanceSQ = panicDistance * panicDistance;
	float distanceSQ = getDistanceSquared(_internalPosition, target);
	
	// we're far away enough not to care
	if(distanceSQ > panicDistanceSQ) {
		return;
	}
	
	_steeringForce = [self steer:target easeAsApproaching:YES withEaseDistance:panicDistance];
	
	// Pass in zero to ignore mutliplier, is this faster than just doing the operation? I dunno
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_steeringForce = ccpNeg(_steeringForce);
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}


-(void) wander:(float)multiplier
{
	_wanderTheta += CCRANDOM_MINUS1_1() * _wanderTurningRadius;
	
	// Add our speed to where we are, plus _wanderDistnace ( how far we project ourselves wandering )
	CGPoint futurePosition = ccp(_velocity.x, _velocity.y);
	futurePosition = normalize( futurePosition );
	futurePosition = ccpMult(futurePosition, _wanderLookAheadDistance);
	futurePosition = ccpAdd(futurePosition, _internalPosition);
	
	// move left or right a little
	CGPoint offset = CGPointZero;
	offset.x = _wanderMaxTurnCircleRadius * cosf(_wanderTheta);
	offset.y = _wanderMaxTurnCircleRadius * sinf(_wanderTheta);
	
	// steer to our new random position
	CGPoint target = ccpAdd(futurePosition, offset);
	_steeringForce = [self steer:target easeAsApproaching:NO withEaseDistance:IGNORE];
	
	if(multiplier != IGNORE)
		_steeringForce = ccpMult(_steeringForce, multiplier);
	
	_acceleration = ccpAdd(_acceleration, _steeringForce);
}


#pragma mark BOX2D collision detection
- (void)createBox2dBodyDefinitions:(b2World*)world{
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
    bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    bodyDef.userData = self;
	bodyDef.fixedRotation = false;
	bodyDef.allowSleep = true;
	bodyDef.awake = true;
    bodyDef.bullet = true;
    
	b2Body* body;
	body = world->CreateBody(&bodyDef);
	
    b2PolygonShape spriteShape;
	
    spriteShape.SetAsBox((self.contentSize.width/PTM_RATIO/2) * self.scale,
                         (self.contentSize.height/PTM_RATIO/2) * self.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = true;
	b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = player;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = predator | harvester | point | bird | bullet;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
    body->CreateFixture(&spriteShapeDef);
}


#pragma mark Deallocation
- (void) dealloc
{
	[super dealloc];
}


#pragma mark -
#pragma mark GETTERS / SETTERS 
- (void) setMaxForce:(float)value
{
	if(value < 0.0f)
		value = 0;
	
	self->_maxForce = value;
	self->_maxForceSQ = value * value;
}
- (void) setMaxSpeed:(float)value
{
	if(value < 0.0f)
		value = 0;
	
	self->_maxSpeed = value;
	self->_maxSpeedSQ = value * value;
}

- (void) setEdgeBehavior:(int)value
{
	if(value != EDGE_WRAP && value != EDGE_BOUNCE) {
		_edgeBehavior = EDGE_NONE;
	}
	
	_edgeBehavior = value;
}

-(void) setPos:(CGPoint)value
{
	self.position = value;
	self->_oldInternalPosition = self->_internalPosition;
	self->_internalPosition = ccp(value.x, value.y);
}

#pragma mark -
#pragma mark Inlined Helper Functions
inline float randRange(float min,float max)
{
	return CCRANDOM_0_1() * (max-min) + min;
}

inline CGPoint normalize(CGPoint point)
{
	float length = sqrtf(point.x*point.x + point.y*point.y);
	if (length < FLT_EPSILON) length = 0.001f; // prevent divide by zero
	
	float invLength = 1.0f / length;
	point.x *= invLength;
	point.y *= invLength;
	
	return point;
}
//#define distanceSquared(__X__, __Y__) ccpLengthSQ( ccpSub(__X__, __Y__) )

inline float getDistanceSquared( CGPoint pointA, CGPoint pointB )
{
	float deltaX = pointB.x - pointA.x;
	float deltaY = pointB.y - pointA.y;
	return (deltaX * deltaX) + (deltaY * deltaX);
}

inline float getDistance( CGPoint pointA, CGPoint pointB )
{
	return sqrtf( getDistanceSquared(pointA, pointB) );
}
@end