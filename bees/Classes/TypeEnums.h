typedef enum PredatorTypes{
	AGGRESSIVE = 0,
	PASSIVE = 1,
	DUMB = 2,
	LAZY = 3,
	MAX_PREDATOR_TYPE = 3
};


typedef enum ParticleTypes{
	ATKA = 0,
	RAIN = 1
};

#define PTM_RATIO 1/300

typedef enum PointTypes{
	ATTACK_BOOST = 1,
	EVADE_BOOST = 2,
	GOLD = 3
};


typedef enum BoostTimes{
	EVADE_BOOST_TIME = 5,
	EVADE_BOOST_TIME_TIME_RACE = 3
};

typedef enum BoidTypes{
	BEE = 0,
	PREDATOR = 1
};

typedef enum TimeToLives{
	TIME_TO_LIVE_BOID_DEATH = 1
};


typedef enum Slots{
	RED_SLOT = 1,
	BLUE_SLOT = 2,
	YELLOW_SLOT = 3,
	BOMB_SLOT = 4,
	SPEED_SLOT = 5,
	REVIVER_SLOT = 6
};

typedef enum Effects{
	BOMB_EFFECT = 1,
	SPEED_EFFECT = 2,
	DISEASE_EFFECT =3,
	SHRINK_EFFECT = 4
	
};

typedef enum Difficulty{
	EASY = 2,
	NORMAL = 1,
	HARD = 0
};

typedef enum GameModes{
	CAMPAIGN = 0,
	SURVIVAL = 1,
	TIME_RACE = 2
};

typedef enum HiveSlots{
	COMBO_FINISHER = 0,
	BEE_MOVEMENT = 1,
	REVIVER = 2
};


typedef enum ComboFinishers{
	BOMB = 0,
	SPEED = 1,
	REVIVE = 2
};

typedef enum BeeMovement{ 
	VELOCITY = 0,
	TURNING = 1,
	COHESION = 2
};

typedef enum Revivers{
	FREEZE = 0,
	SIZE = 1,
	STONE = 2
};