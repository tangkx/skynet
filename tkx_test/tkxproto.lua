local sprotoparser = require "sprotoparser"

local tkxproto = {}

tkxproto.c2s = sprotoparser.parse [[

.package{
	type 0 : integer
	session 1 : integer
}

login 1 {
	request{
		account 0 : string
		password 1 : string
	}

	response{
		result 0 : string
	}

}

get 2 {
	request {
		what 0 : string
	}
	response {
		result 0 : string
	}
}

set 3 {
	request {
		what 0 : string
		value 1 : string
	}
}

quit 4 {}

]]


tkxproto.s2c = sprotoparser.parse [[

.package{
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}
]]