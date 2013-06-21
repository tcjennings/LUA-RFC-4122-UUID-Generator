--[[
The MIT License (MIT)
Copyright (c) 2012 Toby Jennings

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--LuaCrypto is a Lua frontend to the OpenSSL crypto library
--Lua rocks is one way to obtain this module
package.cpath=package.cpath .. ";/opt/local/share/luarocks/lib/lua/5.1/?.so"
local crypto = require("crypto")

local M = {}
-----
local function num2bs(num)
	local _mod = math.fmod or math.mod
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
local function hex2dec(hex)
	local _sub = string.sub
	local dec = 0
	local nibbles=string.len(hex)
	local valTable = {}
	local hex = string.upper(hex)
	--
	local position=1
	for i=nibbles,1,-1 do
		valTable[position]=_sub(hex,i,i)
		position=position+1
	end
	--
	for i,v in ipairs(valTable) do
		if     v=="A" then v=10
		elseif v=="B" then v=11
		elseif v=="C" then v=12
		elseif v=="D" then v=13
		elseif v=="E" then v=14
		elseif v=="F" then v=15
		end
		local newVal=v*math.pow(16,i-1)
		dec=dec+newVal
	end
	--
	return dec
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
local function getUUID(name,nameSpace)
	--For a v5 UUID, some common namespaces are specified in RFC4122.
	--This module will support these as well as provide an internal
	--Namespace UUID for arbitrary strings
	local namespaceUUID
	if nameSpace == "nsURL" then
		nameSpaceUUID="6ba7b811-9dad-11d1-80b4-00c04fd430c8"
	elseif nameSpace == "nsDNS" then
		nameSpaceUUID="6ba7b810-9dad-11d1-80b4-00c04fd430c8"
	elseif nameSpace == "nsOID" then
		nameSpaceUUID="6ba7b812-9dad-11d1-80b4-00c04fd430c8"
	elseif nameSpace == "nsX500" then
		nameSpaceUUID="6ba7b814-9dad-11d1-80b4-00c04fd430c8"
	else
		--an arbitrary v4 UUID--
		nameSpaceUUID="51C3AF2C-0C43-410E-9F1B-CA01FF66333E"
	end
	
	local _hash = crypto.digest
	local _rnd = math.random
	local _fmt = string.format
	local _sub = string.sub
	local _upper = string.upper
	--
	local nameHash = _hash.new("sha1")
	nameHash:update(nameSpaceUUID)
	nameHash:update(name)
	nameHash = nameHash:final()
	--
	local time_low = _sub(nameHash,33,40)
	--
	local time_mid = _sub(nameHash,29,32)
	--
	local time_hi = _sub(nameHash,25,28)
	time_hi = padbits( num2bs( hex2dec(time_hi) ),16 )
	local version = "0101"
	time_hi_and_version= bs2num( version .. _sub(time_hi,5,16) )
	--
	local clock_seq_hi_res = _sub(nameHash,23,24)
	clock_seq_hi_res = padbits( num2bs(hex2dec(clock_seq_hi_res)), 8 )
	clock_seq_hi_res = bs2num( "10" .. _sub(clock_seq_hi_res,3,8) )
	--
	local clock_seq_low = _sub(nameHash,21,22)
	--
	local node = _sub(nameHash,9,20)
	--
	local guid=""
	
	guid = guid .. padbits(_upper(time_low),8) .. "-"
	guid = guid .. padbits(_upper(time_mid),4) .. "-"
	guid = guid .. padbits(_fmt("%X",time_hi_and_version), 4) .. "-"
	guid = guid .. padbits(_fmt("%X",clock_seq_hi_res), 2)
	guid = guid .. padbits(_upper(clock_seq_low),2) .. "-"
	guid = guid .. padbits(_upper(node),12)
	--
	return guid
end
--
M.getUUID = getUUID
return M