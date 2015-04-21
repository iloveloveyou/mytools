--[[

]]--





Web = {
	flag = 'AC', 
	tokey = '^YHN*IK<'
}

function Web:reWrite(url)

	 ngx.req.set_uri(url, true); -- rewrite

	--url = url .. '.rw';
	--local res = ngx.location.capture(url,{});
	--ngx.say(res.body);
	--ngx.exit(ngx.HTTP_OK);
end

function Web:notFound()
	ngx.exit(ngx.HTTP_NOT_FOUND);
end


function Web:getIp()
	return ngx.var.remote_addr;
end
----------------------------  tool ---

function Web:strSplit(str, split)
  local list = {}
  
  if split == '' then
  	length = string.len(str)

	for i=1, length, 1 do 
		table.insert(list, string.sub(str, i, i))
	end
	return list
  end
   
  local pos = 1
  while 1 do
    local first, last = string.find(str, split, pos)
    if first then -- found?
      table.insert(list, string.sub(str, pos, first-1))
      pos = last+1
    else
      table.insert(list, string.sub(str, pos))
      break
    end
  end
  return list
end

function Web:printArr(args)
	for key, val in pairs(args) do
		if type(val) == "table" then
		    ngx.say(key, ": ", table.concat(val, ", "))
		else
		    ngx.say(key, ": ", val)
		end
	end
end


function Web:write(str)
	if str ~= nil then
		local imgPath = luaPath .. '../../logs/lua.log';
		local f = assert(io.open(imgPath, "a"));
		f:write(str);
		f:close();
	end
end

function Web:getCookie()

	local cookieStr = ngx.unescape_uri(ngx.req.get_headers()['Cookie']);
	local cookieArr = self:strSplit(cookieStr, '; ');
	local cookieTemp = {};
	local cookieGet = {};
	for key, val in pairs(cookieArr) do
		cookieTemp = self:strSplit(val, '=');
		cookieGet[cookieTemp[1]] = cookieTemp[2];
	end
	return cookieGet;
end

-------------------  定义 FUNCTION  结束


local cookies = Web:getCookie();

local ip = Web:getIp();


if cookies[ip] == nil or cookies[ip] == '' or cookies[Web.flag] == nil or cookies[Web.flag] == '' then
	Web:notFound ();
end

local flagArr = Web:strSplit(cookies[Web.flag], '|');

if flagArr[2] == nil or flagArr[2] == ''  then
	Web:notFound ();
end

local md5Str = ngx.md5(flagArr[2] .. Web.tokey);




if md5Str ~= flagArr[1] then
	Web:notFound ();
end



local diffTime = ngx.time() - tonumber(flagArr[2]);

if diffTime > 3600  then
	Web:notFound ();
end


-- 40 到 60 分之间时更新COOKIE
if diffTime >  2400  and diffTime <= 3600 then


		local time = ngx.time();
		local str = ngx.md5(time .. Web.tokey) .. "|" .. time;

		local path = "/";
		local cookieArr = {};
		-- table.insert(cookieArr,ip .. "=" ..ip .. "; path=" .. path);
		table.insert(cookieArr, Web.flag .."=" .. str .. "; path=" .. path);
		ngx.header["Set-Cookie"] = cookieArr;

end


-- URL 重写
-- Web:reWrite(ngx.var.rw);

