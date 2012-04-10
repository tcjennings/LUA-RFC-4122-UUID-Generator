local M = {}
-----
local function num2bs(num)
	local _mod = math.mod
	local _floor = math.floor
	--
	local index, result = 1 , ""
	if(num == 0) then return "0" end
	while(num  > 0) do
		 result = _mod(num,2) .. result
		 num = _floor(num*0.5)
	end              
	return result
end
--
local function bs2num(num)
	local _sub = string.sub
	local index, result = 0, 0
	if(num == "0") then return 0; end
	for p=#num,1,-1 do
		local this_val = _sub( num, p,p )
		if this_val == "1" then
			result = result + ( 2^index )
		end
		index=index+1
	end
	return result
end
--
local function padbits(num,bits)
	if #num == bits then return num end
	if #num > bits then print("too many bits") end
	local pad = bits - #num
	for i=1,pad do
		num = "0" .. num
	end
	return num
end
--
local function getUUID()
	local _rnd = math.random
	local _sub = string.sub
	local _fmt = string.format
	--
	local time_low = os.time()
	math.randomseed( time_low )
	--
	local time_mid = _rnd(0, 65535)
	--
	local time_hi = _rnd(0, 65535 )
	time_hi = padbits( num2bs(time_hi), 16 )
	time_hi = _sub( time_hi, 1, 12 )
	local time_hi_and_version = bs2num( time_hi .. "0100" )
	--
	local clock_seq_hi_res = _rnd(0,255)
	clock_seq_hi_res = padbits( num2bs(clock_seq_hi_res), 8 )
	clock_seq_hi_res = _sub( clock_seq_hi_res, 1, 6) .. "01"
	--
	local clock_seq_low = _rnd(0,255)
	clock_seq_low = padbits( num2bs(clock_seq_low), 8 )
	--
	local clock_seq = bs2num(clock_seq_hi_res .. clock_seq_low)
	--
	local node = {}
	node[1]= (128 + _rnd(0,127) )
	for i=2,6 do
		node[i] = _rnd(0,255)
	end
	--
	local guid = ""
	guid = guid .. padbits(_fmt("%X",time_low), 8) .. "-"
	guid = guid .. padbits(_fmt("%X",time_mid), 4) .. "-"
	guid = guid .. padbits(_fmt("%X",time_hi_and_version), 4) .. "-"
	guid = guid .. padbits(_fmt("%X",clock_seq), 4) .. "-"
	--
	for i=1,6 do
		guid = guid .. padbits(_fmt("%X",node[i]), 2)
	end
	--
	return guid
end
--
M.getUUID = getUUID
return M