local uuid4= require("uuid4")
local uuid5= require("uuid5")

--A v4 UUID
print( uuid4.getUUID() )

--SOME v5 UUIDs

--An arbitary name
print( uuid5.getUUID("A Name") )

--A FQDN
print( uuid5.getUUID("www.google.com","nsDNS") )

--A URL
print( uuid5.getUUID("http://en.wikipedia.org/Universally_unique_identifier","nsURL") )

