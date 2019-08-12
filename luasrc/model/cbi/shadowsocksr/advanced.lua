local shadowsocksr = "shadowsocksr"
local uci = luci.model.uci.cursor()
local server_table = {}

uci:foreach(shadowsocksr, "servers", function(s)
	if s.alias then
		server_table[s[".name"]] = "[%s]:%s" %{string.upper(s.type), s.alias}
	elseif s.server and s.server_port then
		server_table[s[".name"]] = "[%s]:%s:%s" %{string.upper(s.type), s.server, s.server_port}
	end
end)

local key_table = {}   
for key,_ in pairs(server_table) do  
    table.insert(key_table,key)  
end 

table.sort(key_table)

m = Map(shadowsocksr)



-- [[ haProxy ]]--

s = m:section(TypedSection, "global_haproxy", translate("haProxy settings"))
s.anonymous = true

o = s:option(Flag, "admin_enable", translate("Enabling the Management Console"))
o.rmempty = false
o.default = 1

o = s:option(Value, "admin_port", translate("Service Port"))
o.datatype = "uinteger"
o.default = 1111

o = s:option(Value, "admin_user", translate("User name"))
o.default = "admin"

o = s:option(Value, "admin_password", translate("Password"))
o.default = "root"

-- [[ SOCKS5 Proxy ]]--
if nixio.fs.access("/usr/bin/ssr-local") then
s = m:section(TypedSection, "socks5_proxy", translate("SOCKS5 Proxy"))
s.anonymous = true

o = s:option(ListValue, "server", translate("Server"))
o:value("nil", translate("Disable"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o.rmempty = false

-- [[ HTTP Proxy ]]--
if nixio.fs.access("/usr/sbin/privoxy") then
o = s:option(Flag, "http_enable", translate("Enable HTTP Proxy"))
o.rmempty = false

o = s:option(Value, "http_port", translate("HTTP Port"))
o.datatype = "port"
o.default = 1081
o.rmempty = false

end
end



return m
