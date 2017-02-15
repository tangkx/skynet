package.cpath = "./cservice/?.so;./luaclib/?.so"
package.path = "lualib/?.lua"

local socket = require "clientsocket"
local cjson = require "cjson"
--local skynet = require "skynet"

local i = 50

local fd = assert(socket.connect("127.0.0.1",9999))
print(".....fd is :",fd)
--local sampleJson = [[{"age":"23","testArray":{"array":"12"},"Himi":"himigame.com"}]]
local jsontable = {}
local array = {}
array["age"] = 100
array["firstname"] = "tang"
jsontable["name"] = "tkx"
jsontable["array"] = array
local jsonstr = cjson.encode(jsontable)
local package = string.pack(">s2", jsonstr)
socket.send(fd, package)
print('ok')
--socket.write(fd,net)
--print(socket.recv(fd))


