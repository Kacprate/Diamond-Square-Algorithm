local DiamondSquare = {}
local p_math = math;

-- Constructor
function DiamondSquare:new()
	local meta = setmetatable({}, self);
	self.__index = self;
	
	return meta;
end

-- additional functions
local Math = {
	min = function(a, b) -- returns minimum of two numbers
		if a > b then return b; else return a; end
	end,
	
	max = function(a, b) -- returns maximum of two numbers
		if a > b then return a; else return b; end
	end,
	
	abs = function(a) -- returns the absolute value of two numbers
		if a < 0 then return -a; else return a; end
	end,
	
	avg = function(...) -- returns the average of elements provided as arguments
		local args = {...};
		local sum = 0;
		for i, v in pairs(args) do
			sum = sum + v;
		end
		
		return (sum/#args);
	end
}

function fixSize(x) -- fixes the size
	local i = 1
	while (x > i + 1) do i = i * 2 end
	return i + 1
end

local function circularSmoothener(sizeX, sizeY, map, factor)
	for i = 1, sizeX, 1 do
		for j = 1, sizeY, 1 do
			local center = p_math.sqrt((i - sizeX/2)*(i - sizeX/2) + (j - sizeY/2)*(j - sizeY/2));
			local smoothenFactor = center/factor + 1;
			map[i][j] = map[i][j] - smoothenFactor;
		end
	end
end

local function getNewMap(sizeX, sizeY)
	local map = {};
	for i = 1, sizeX, 1 do
		map[i] = {};
		for j = 1, sizeY, 1 do
			map[i][j] = 0;
		end
	end
	return map;
end

local function copyMap(map0, map1)
	for i = 1, #map0, 1 do
		for j = 1, #map0[1], 1 do
			map0[i][j] = map1[i][j];
		end
	end
end

function DiamondSquare.Generate(x, y, minHeight, maxHeight, diamondNoise, squareNoise, randomness, allowDiamondNegative, diamondFactor, sum_part_power, performSmoothening, smoothenerFactor)
	local max 	= Math.max(x, y); -- saves the maximum of x and y
	local fixed = fixSize(max); -- fixed size
	local X, Y 	= fixed, fixed; -- new size for generation purposes, now we are generating a square
	local step 	= fixed - 1; -- iteration step in the diamond square algorithm
	local originalStep = step;
	local map = {}; -- temporary map

	local function local_createMap()
		for i = 1, X, 1 do
			map[i] = {};
		end
	end

	local function fillMap(n)
		for i = 1, X, 1 do
			for j = 1, Y, 1 do
				map[i][j] = n;
			end
		end
	end

	local_createMap();
	fillMap(0);

	local function makeCorners()
		map[1][1]	= p_math.random(minHeight, maxHeight);
		map[1][Y]	= p_math.random(minHeight, maxHeight);
		map[X][1]	= p_math.random(minHeight, maxHeight);
		map[X][Y]	= p_math.random(minHeight, maxHeight);
	end

	local function diamond(x, y, step)
		local a = map[x][y];
		local b = map[x][y + step];
		local c = map[x + step][y + step];
		local d = map[x + step][y];
		
		local midPoint_X, midPoint_Y = x + step/2, y + step/2;

		--[[
			a -- b
			|    |
			d -- c
		--]]
		local sum_part =  (p_math.random(-diamondNoise*1000 * allowDiamondNegative, diamondNoise*1000)/1000)*randomness*(diamondFactor*step/originalStep);
		if (sum_part_power) then
			sum_part = sum_part * (diamondFactor*step/originalStep);
		end
		local avg = Math.avg(a, b, c, d) + sum_part;
		map[midPoint_X][midPoint_Y] = avg;
	end

	local function getSquareValue(x, y, step)
		local count = 0;
		local sum = 0;

		if x - step/2 > 0 then
			count = count + 1;
			sum = sum + map[x - step/2][y];
		end
		
		if y + step/2 <= Y then
			count = count + 1;
			sum = sum + map[x][y + step/2];
		end
		
		if x + step/2 <= X then
			count = count + 1;
			sum = sum + map[x + step/2][y];
		end
		
		if y - step/2 > 0 then
			count = count + 1;
			sum = sum + map[x][y - step/2];
		end

		return sum/count;
	end

	local function square(x, y, step)
		if y + step/2 <= Y then
			map[x][y + step/2] = getSquareValue(x, y + step/2, step) + (p_math.random(-squareNoise*1000, squareNoise*1000)/1000)*randomness*(step/originalStep);
		end
		if x + step/2 <= X then
			map[x + step/2][y] = getSquareValue(x + step/2, y, step) + (p_math.random(-squareNoise*1000, squareNoise*1000)/1000)*randomness*(step/originalStep);
		end
		if x + step/2 <= X and y + step <= Y then
			map[x + step/2][y + step] = getSquareValue(x + step/2, y + step, step) + (p_math.random(-squareNoise*1000, squareNoise*1000)/1000)*randomness*(step/originalStep);
		end
		if x + step <= X and y + step/2 <= Y then
			map[x + step][y + step/2] = getSquareValue(x + step, y + step/2, step) + (p_math.random(-squareNoise*1000, squareNoise*1000)/1000)*randomness*(step/originalStep);
		end
	end

	makeCorners()

	while step > 1 do
		for i = 1, X - 1, step do
			for j = 1, X - 1, step do
				diamond(i, j, step);
			end
		end
		
		for i = 1, X - 1, step do
			for j = 1, X - 1, step do
				square(i, j, step);
			end
		end
		step = p_math.floor(step/2);
	end	
	
	if performSmoothening then
		circularSmoothener(x, y, map, smoothenerFactor);
	end
	
	local final_map = getNewMap(x, y);
	copyMap(final_map, map);
	final_map.x = x;
	final_map.y = y;
	
	return final_map;
end

return DiamondSquare;
