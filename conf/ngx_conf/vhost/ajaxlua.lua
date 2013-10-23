--[[

]]--

luaPath = ngx.var.luaPath;


Auth = {
	keyPreFix = 'pre_', 
	keyLen = 4,
	lifeTime = 600,

	redisDb = 1,
	redisLifeTime = 600,
	ajaxTimeOut = 60
}

gameNumberName = {
   k_0000 = '第 1 球_0',
   k_0001 = '第 1 球_1',
   k_0002 = '第 1 球_2',
   k_0003 = '第 1 球_3',
   k_0004 = '第 1 球_4',
   k_0005 = '第 1 球_5',
   k_0006 = '第 1 球_6',
   k_0007 = '第 1 球_7',
   k_0008 = '第 1 球_8',
   k_0009 = '第 1 球_9',
   k_0010 = '第 2 球_0',
   k_0011 = '第 2 球_1',
   k_0012 = '第 2 球_2',
   k_0013 = '第 2 球_3',
   k_0014 = '第 2 球_4',
   k_0015 = '第 2 球_5',
   k_0016 = '第 2 球_6',
   k_0017 = '第 2 球_7',
   k_0018 = '第 2 球_8',
   k_0019 = '第 2 球_9',
   k_0020 = '第 3 球_0',
   k_0021 = '第 3 球_1',
   k_0022 = '第 3 球_2',
   k_0023 = '第 3 球_3',
   k_0024 = '第 3 球_4',
   k_0025 = '第 3 球_5',
   k_0026 = '第 3 球_6',
   k_0027 = '第 3 球_7',
   k_0028 = '第 3 球_8',
   k_0029 = '第 3 球_9',
   k_0030 = '第 4 球_0',
   k_0031 = '第 4 球_1',
   k_0032 = '第 4 球_2',
   k_0033 = '第 4 球_3',
   k_0034 = '第 4 球_4',
   k_0035 = '第 4 球_5',
   k_0036 = '第 4 球_6',
   k_0037 = '第 4 球_7',
   k_0038 = '第 4 球_8',
   k_0039 = '第 4 球_9',
   k_0040 = '第 5 球_0',
   k_0041 = '第 5 球_1',
   k_0042 = '第 5 球_2',
   k_0043 = '第 5 球_3',
   k_0044 = '第 5 球_4',
   k_0045 = '第 5 球_5',
   k_0046 = '第 5 球_6',
   k_0047 = '第 5 球_7',
   k_0048 = '第 5 球_8',
   k_0049 = '第 5 球_9',
   k_0050 = '第 1 球_单',
   k_0051 = '第 1 球_双',
   k_0052 = '第 1 球_大',
   k_0053 = '第 1 球_小',
   k_0060 = '第 2 球_单',
   k_0061 = '第 2 球_双',
   k_0062 = '第 2 球_大',
   k_0063 = '第 2 球_小',
   k_0070 = '第 3 球_单',
   k_0071 = '第 3 球_双',
   k_0072 = '第 3 球_大',
   k_0073 = '第 3 球_小',
   k_0080 = '第 4 球_单',
   k_0081 = '第 4 球_双',
   k_0082 = '第 4 球_大',
   k_0083 = '第 4 球_小',
   k_0090 = '第 5 球_单',
   k_0091 = '第 5 球_双',
   k_0092 = '第 5 球_大',
   k_0093 = '第 5 球_小',
   k_0100 = '总和_单',
   k_0101 = '总和_双',
   k_0102 = '总和_大',
   k_0103 = '总和_小',
   k_0110 = '龙_',
   k_0120 = '虎_',
   k_0130 = '和_',
   k_0140 = '前三_豹子',
   k_0150 = '中三_豹子',
   k_0160 = '后三_豹子',
   k_0170 = '前三_顺子',
   k_0180 = '中三_顺子',
   k_0190 = '后三_顺子',
   k_0200 = '前三_对子',
   k_0210 = '中三_对子',
   k_0220 = '后三_对子',
   k_0230 = '前三_半顺',
   k_0240 = '中三_半顺',
   k_0250 = '后三_半顺',
   k_0260 = '前三_杂六',
   k_0270 = '中三_杂六',
   k_0280 = '后三_杂六'
} 





function Auth:longQ()

	local nowTime = ngx.time();
	ngx.req.read_body();
	local args = ngx.req.get_post_args();
	
	if tonumber(args.corpID) == nil then
		ngx.say("error");
		ngx.exit(ngx.HTTP_OK);
	end

	local info = false;

	 while true do
		
		info = self:redisGet(self.redisDb, 'corp_' .. args.corpID .. '_com');
		if info == false or info == nil then
			-- redis 取不到数据
			ngx.say(args.time);
			ngx.exit(ngx.HTTP_OK);
		elseif nowTime + Auth.ajaxTimeOut < ngx.time() then
			-- ajax 超时
			ngx.say(args.time);
			ngx.exit(ngx.HTTP_OK);
		elseif args.time == nil or args.time == 0 or args.time < info then
			-- ajax第一次请求或有数据更新
			ngx.say(info);
			ngx.exit(ngx.HTTP_OK);
		end
		
		Auth:sleep(1);
	 end
	
end


function Auth:setFlag()
	ngx.req.read_body();
	local args = ngx.req.get_post_args(); -- ngx.req.get_uri_args();
 	local nowTime = ngx.time();
	if tonumber(args.corpID) ~= nil then
		self:redisSet(self.redisDb, 'corp_' .. args.corpID .. '_com', nowTime, self.redisLifeTime);
		ngx.say(nowTime);
	else
		ngx.say('error');
	end
end



function Auth:testLua(type)

	local str = 'd8dcdfCw0OChMNDhMLE35efn5efnY0NTg0';
	local verifyCode = self.keyPreFix .. ngx.time();
	local encryStr = self:enCode(str, verifyCode, ngx.time() + self.lifeTime);
	local data =  self:deCode(encryStr, verifyCode);
	if type == nil then 
		ngx.say('测试登录验证字符串的加密解密：');
		ngx.say(encryStr);
	else
		return encryStr;
	end
end


function Auth:testMysql(type)
	

	local sql = "SELECT * FROM long_queues where continue_number >= 2 and game_id in ('005','006','007','008','009','010','011','012','013') order by continue_number desc,sequence asc limit 50";
	local data = self:query(sql);
	local gameName = '';
	local msg = '';
	for k, v in pairs(data) do
		gameName =  self:strSplit(gameNumberName['k_' .. string.format("%03d", v.game_id) .. v.number], '_');
		
		msg = msg .. gameName[1] ..' ' .. gameName[2] .. ': ' .. v.continue_number .. "\n";
	end
	if type == nil then 
		ngx.say('ssc长龙排行：');
		ngx.say(msg);
	else
		return msg;
	end

end

function Auth:testRedis(type)

	self:redisSet(self.redisDb, 'redisTest', ngx.time(), self.redisLifeTime);
	local info = self:redisGet(self.redisDb, 'redisTest');
	if type == nil then 
		ngx.say('redis 存取测试：' .. info);
	else
		return info;
	end

end

-- ---------------------------------Utils----------------------------

function Auth:sleep(second)
   ngx.sleep(second);
end


-- 执行 SQl
function Auth:query(doSql, type)

	local json = require "cjson"

	local res = ngx.location.capture("/query", { method = ngx.HTTP_POST, body = "", args = {sql = doSql} }) 
	
	local tid = res.header["X-Mysql-Tid"];
        if tid and tid ~= "" then
  		ngx.location.capture("/kill", { args = {tid = tid} })
        end

	if res.status == ngx.HTTP_OK and res.body ~='[]' then
		return type == nil and json.decode(res.body) or res.body;
	else
		return nil;
	end

end


function Auth:redisSet(db, key, value, expire)

	local cmds = {
		{"select", db},
	        {"set", key, value}
	    }
	if expire ~= nil then
		cmds[3] = {"expire", key, expire};
	end
	
	replies = self:redisMuti(cmds);
	

	local replie = true;
	for i, result in ipairs(replies) do
		if result[1] ~= 'OK' and result[1] ~= 1 then
			ngx.log(ngx.ERR, 'redisSet:' .. key .. ':' .. value  .. ' ;expire:' .. expire  .. ' -- errInfo:'.. result[1]);
			replie = false;
		end
	end
	return replie;

end

function Auth:redisGet(db, key)

	local cmds = {
		{"select", db},
	        {"get", key}
	    }
	
	replies = self:redisMuti(cmds);
	local replie = false;
	if replies[2][1] == nil then
		ngx.log(ngx.ERR, 'redisGet:' .. key .. ' --- 取不到数据');
	else
		replie = replies[2][1];
	end

	return replie;

end


function Auth:redisRpush(db, key, value)

	local cmds = {
		{"select", db},
	        {"rpush", key, value}
	    }
	
	replies = self:redisMuti(cmds);
	

	local replie = true;
	for i, result in ipairs(replies) do
		if result[1] ~= 'OK' and tonumber(result[1]) == nil then
			ngx.log(ngx.ERR, 'redisRpush:' .. key .. ':' .. value  .. ' -- errInfo:'.. result[1]);
			replie = false;
		end
	end
	return replie;

end


function Auth:redisKeys(db, key)

	local cmds = {
		{"select", db},
		{"keys", key}
	    }
	
	local replies = self:redisMuti(cmds)[2][1];
	replies = replies ~= nil and replies or false;

	return replies;

end

-- 执行多个redis命令
function Auth:redisMuti(cmds)
	
	--[[
		local cmds = {
			{"select", 5},
		        {"set", "foo", "hello world 555"},
		        {"get", "foo"}
		    }
	]]--

	local parser = require "redis.parser";

	local raw_reqs = {}
	for i, req in ipairs(cmds) do
		table.insert(raw_reqs, parser.build_query(req))
	end
	
	local nums = table.getn(raw_reqs);


	local res = ngx.location.capture('/redisDoMuti/',
            { args = {
		n = nums,
	        cmds = table.concat(raw_reqs, "")
              }
            }
        )


	if res.status ~= 200 or not res.body then
		ngx.log(ngx.ERR, "failed to query redis");
		ngx.exit(500)
	end


	local replies = parser.parse_replies(res.body, nums);
	
	--[[
		for i, result in ipairs(replies) do
			local res = result[1]
			ngx.say(res);
		end
	]]--
	return replies;

end


function Auth:getCookie()

	local cookieStr = ngx.req.get_headers()['Cookie'];
	local cookieArr = self:strSplit(cookieStr, ';');
	local cookieTemp = {};
	local cookieGet = {};
	for key, val in pairs(cookieArr) do
		cookieTemp = self:strSplit(val, '=');
		cookieGet[cookieTemp[1]] = cookieTemp[2];
	end
	return cookieGet;
end


function Auth:strSplit(str, split)
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

function Auth:printArr(args)
	for key, val in pairs(args) do
		if type(val) == "table" then
		    ngx.say(key, ": ", table.concat(val, ", "))
		else
		    ngx.say(key, ": ", val)
		end
	end
end


-- 加密
function Auth:enCode(str, verifyCode, lifeTime)

	local expiry  = lifeTime == nil and (self.lifeTime + ngx.time()) or lifeTime;
        local keyc = string.sub(ngx.md5(self.keyPreFix..ngx.now()..string.sub(str, 0, self.keyLen)), - self.keyLen);
	
	-- ngx.say(ngx.time(),'--',expiry,'--',os.date("%Y-%m-%d %H:%M:%S", expiry));

	--  加密时间
	local keyd = self:strSplit(string.byte(self:strSplit(keyc, '')[1]), '')[1];
	local expiryArr = self:strSplit(expiry, '');
	local expiryArrLen = table.getn(expiryArr);
	local newExpiry = '';
	for i=1, expiryArrLen, 1 do
		newExpiry = newExpiry .. string.char(keyd..expiryArr[i]);
	end
	-- 加密时间 end
	-- ngx.say(ngx.md5(keyc .. newExpiry),'--',keyc,'--',string.gsub(ngx.encode_base64(newExpiry),'=',''));
	local baseVerifyCode = verifyCode == '' and '' or string.gsub(ngx.encode_base64(newExpiry .. '~^~~^~' .. verifyCode),'=','')
	return  ngx.md5(keyc .. newExpiry) .. keyc .. baseVerifyCode;
end

-- 解密
function Auth:deCode(str, verifyCode)

	local verifyStr = string.sub(str, 1, 32);
	local keyc = string.sub(str, 33, 32 + self.keyLen);
	local code = self:strSplit(ngx.decode_base64(string.sub(str, 33+self.keyLen, -1)), '~^~~^~');
	local newExpiry = code[1];
	local oldVerifyCode = code[2];
	if verifyCode ~= nil and oldVerifyCode ~= verifyCode then
		return 'e1';
	elseif  verifyStr ~= ngx.md5(keyc .. newExpiry) then
		return 'e2';
	end
	
	-- 解密时间
	-- keyd = self:strSplit(string.byte(self:strSplit(keyc, '')[1]), '')[1]; -- 备用verifyKey
	local newExpiryArr = self:strSplit(newExpiry, '');
	local newExpiryLen = table.getn(newExpiryArr);
	local expiry = '';
	for i=1, newExpiryLen, 1 do
		expiry = expiry .. self:strSplit(string.byte(newExpiryArr[i]), '')[2];
	end
	-- 解密时间 end

	-- ngx.say(tonumber(expiry - ngx.time()), '--', os.date("%Y-%m-%d %H:%M:%S", expiry));

	if ngx.now() > tonumber(expiry) then
		return 'e3';
	end

	return verifyCode == nil and oldVerifyCode or true;
end