--[[
 登录验证相关

]]--

luaPath = ngx.var.luaPath;
-- 设置Lua登录后的跳转地址
webUrl = 'http://host/';
hubUrl = 'http://host/';


dofile(luaPath .. 'vcode/vcodeConfig.lua');



Auth = {
	keyPreFix = 'pre_', 
	keyLen = 4,
	lifeTime = 600,
	redisDbIP = 'redis_sess',
	redisDb = 1,
	redisDbLifeTime = 3000,
	ukeyLifeTime = 3600,
	errCodeF = {	
			e0 = '验证码已过期,请重新刷新。',
			e1 = '您输入的验证码不正确。',
			e2 = '您输入的用户名或密码不正确,请检查。',
			e3 = '尊敬的会员,您未开通此玩法权限,请与管理员联系。',
			e4 = '尊敬的会员,此账号未启用,请与管理员联系。',
			e5 = '尊敬的会员,此账户已经被停用,请与管理员联系。',
			e6 = '该账户已被锁定,请联系上级更改密码重新登录。',
			e7 = '尊敬的会员,后台已停用,请与管理员联系。',
			e8 = '尊敬的会员,后台维护中,请与管理员联系。',
			e9 = '尊敬的会员,系统出错,请与管理员联系。',
			e10 = '公司不存在,请与管理员联系。'
		},
	errCodeAC = {	
			e0 = '验证码已过期,请重新刷新。',
			e1 = '您输入的验证码不正确。',
			e2 = '您输入的用户名或密码不正确,请检查。',
			e3 = '您未开通此玩法权限,请与管理员联系。',
			e4 = '此账号未启用,请与管理员联系。',
			e5 = '此账户已经被停用,请与管理员联系。',
			e6 = '该账户已被锁定,请联系上级更改密码重新登录。',
			e7 = '后台已停用,请与管理员联系。',
			e8 = '后台维护中,请与管理员联系。',
			e9 = '系统出错,请与管理员联系。',
			e10 = '公司不存在,请与管理员联系。'
		},
	errCodeHub = {	
			e0 = '账号或密码有误，登入失败。',
			e1 = '登录失败超过5次，账号已停用，请与管理员联系。',
			e2 = '账号已经被停用，请与管理员联系。',
			e3 = '系统出错,请与管理员联系。'
		},
	testCorp = { -- 测试公司验证码显示为 1111 ;配制为公司拼音名+数据标识;示例：c0 = 'dev60',c1 = 'abs123'
			c0 = 'aa11',
			c1 = 'ab22',
			c2 = 'ac33',
			c3 = 'ad44',
			c4 = 'ae55',
			c5 = 'af66',
			c6 = 'ag77',
			c7 = 'ah88',
			c8 = 'ai99',
			c9 = 'aj111',
			c10 = 'ba11',
			c11 = 'bb22',
			c12 = 'bc33',
			c13 = 'bd44',
			c14 = 'be55',
			c15 = 'bf66',
			c16 = 'bg77',
			c17 = 'bh88',
			c18 = 'bi99',
			c19 = 'bj111',
			c20 = 'twa11',
			c21 = 'twb22',
			c22 = 'twc33',
			c23 = 'twd44',
			c24 = 'twe55',
			c25 = 'twf66',
			c26 = 'twg77',
			c27 = 'twh88',
			c28 = 'twi99',
			c29 = 'twj111',
			c30 = 'ca11',
			c31 = 'cb22',
			c32 = 'cc33',
			c33 = 'cd44',
			c34 = 'ce55',
			c35 = 'da11',
			c36 = 'db22',
			c37 = 'dc33',
			c38 = 'dd44',
			c39 = 'de55'
		}
}


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

-- 取得随机验证码信息
function Auth:getCodeInfo()
	
 	local args = ngx.req.get_uri_args()

	vcodeConfig = self:getCodeConfig();

	local keyArr = {};
	for i,v in pairs(vcodeConfig.codeKey) do

		table.insert(keyArr, i);

	end

	local key = keyArr[math.random(1,table.getn(keyArr))];
	local vinfo = self:enCode(args.u == nil and ngx.now() or args.u, vcodeConfig.codeKey[key])
	ngx.say(key, '_', vinfo, '_', math.random(1, ngx.now()));

end

-- 取得验证码配制信息
function Auth:getCodeConfig()
	local codeConfig = vcodeConfig;
	local corpFlag = self:strSplit(ngx.var.HTTP_REFERER, '/')[4];
	corpFlag = string.sub(corpFlag, 1, -2);
	for i,v in pairs(self.testCorp) do

		if corpFlag == v then
			isTestCorp = true;
				-- 切换为Test公司认证码
				codeConfig = testVcodeConfig;
			break;
		end

	end
	return codeConfig;
end

-- 取得验证验证码信息
function Auth:vCode()

	local corpFlag = self:strSplit(ngx.var.HTTP_REFERER, '/')[4];
	local userType = string.sub(corpFlag,-1);
	local errInfo = userType == 'f' and self.errCodeF or self.errCodeAC;

	ngx.req.read_body();
 	local args = ngx.req.get_post_args();

	if args.__VerifyValue == nil or args.cid == nil then
		ngx.say(errInfo.e2);
		return false; 
		--ngx.exit(ngx.HTTP_FORBIDDEN);
	end
	
	vcodeConfig = self:getCodeConfig();

	if vcodeConfig.vcode['v' .. args.VerifyCode] == nil then
	
		ngx.say(errInfo.e1);
		return false;
	
	end

	local vc = self:deCode(args.__VerifyValue, 'v' .. args.VerifyCode);

	if vc == 'e1' then
		ngx.say(errInfo.e1);
		return false;
	elseif vc == 'e2' then
		-- 验证字符串不合法
		ngx.log(ngx.INFO,'验证字符串不合法');
		ngx.say(errInfo.e1);
		return false;
	elseif vc == 'e3' then
		-- 已过有效期
		ngx.say(errInfo.e0);
		return false;
	end


	local sql = "SELECT 1";

	local dataArr = self:query(sql);
	if dataArr == nil then
		ngx.say(errInfo.e9);
		return false;
	end

	-- 公司状态验证
	sql = 'select pinyin_name,status from corporation where id = '..tonumber(args.cid);
 	dataArr = self:query(sql);
	
	if dataArr == nil then
		ngx.say(errInfo.e10);
		return false;
	elseif dataArr[1].status == 0 then
		ngx.say(errInfo.e7);
		return false;
	elseif dataArr[1].status == 2 then
		ngx.say(errInfo.e8);
		return false;
	end
	
	local corpPinyinName = dataArr[1].pinyin_name;
	
	-- 会员账号验证
	sql = "SELECT id,status,password,fail_times,limit_login FROM " .. corpPinyinName  .. "_user WHERE account = '" .. args.__name .. "'";

	dataArr = self:query(sql);
	
	if dataArr == nil then
		ngx.say(errInfo.e2);
		return false;
	elseif dataArr[1].limit_login == 1 then -- 登录10次失败后15分钟后解锁
		local expSql = "SELECT (900+UNIX_TIMESTAMP(login_time)-UNIX_TIMESTAMP()) AS diftime FROM " .. corpPinyinName  .. "_user_info WHERE user_id = " .. dataArr[1].id;
		expUserInfo = self:query(expSql);
		if expUserInfo[1].diftime == nil or expUserInfo[1].diftime > 0 then
			-- expUserInfo[1].diftime 秒后可以登录
			ngx.say("输入错误密码超过 10 次,请等候 " .. math.ceil(expUserInfo[1].diftime / 60) .. " 分钟再登录"); -- errInfo.e6
			return false;
		end
	end
	if dataArr[1].password ~=  ngx.md5(args.password) then

		-- 判断是否受登录失败相关的限制
		local userLevelSql =  "SELECT (900+UNIX_TIMESTAMP(login_time)-UNIX_TIMESTAMP()) AS diftime, level FROM " .. corpPinyinName  .. "_user_info WHERE user_id = " .. dataArr[1].id;
		local userLevelArr = self:query(userLevelSql);
		-- userID = 1的超级管理员、用户不在相应的登录页登录的，不受限制
		local needLimit = true;
		if userType == 'f' and userLevelArr[1].level == 5 then
			needLimit = true;
		elseif userType == 'a' and userLevelArr[1].level > 0 and userLevelArr[1].level < 5 then
			needLimit = true;
		elseif userType == 'c' and userLevelArr[1].level == 0  and dataArr[1].id > 1 then
			-- 公司子管理员
			needLimit = true;
		else
			needLimit = false;
		end

		-- 1.2.5版本后，去掉登录限制功能
		needLimit = false;

		if needLimit == true then
			 
			 if (dataArr[1].fail_times > 0 or dataArr[1].limit_login == 1) and userLevelArr[1].diftime <= 0 then
				-- 登录失败大于1次后，等15分钟后，再次登录失败，fail_times 记为1次
				sql = "UPDATE " .. corpPinyinName  .. "_user SET limit_login = 0, fail_times = 1 WHERE id = " .. dataArr[1].id;
			 elseif dataArr[1].fail_times + 1 >= 10 then
				sql = "UPDATE " .. corpPinyinName  .. "_user SET limit_login = 1, fail_times = 0 WHERE id = " .. dataArr[1].id;
			 else
				sql = "UPDATE " .. corpPinyinName  .. "_user SET limit_login = 0, fail_times = fail_times + 1 WHERE id = " .. dataArr[1].id;
			 end
		
			self:query(sql);
			-- 更新最后登录时间
			sql = "	UPDATE " .. corpPinyinName  .. "_user_info SET login_time = NOW() WHERE user_id = " .. dataArr[1].id ;
			self:query(sql);
		end
		ngx.say(errInfo.e2);
		return false;
	end

	-- 用户状态验证
	if dataArr[1].status == 4 then
		ngx.say(errInfo.e2);
		return false;
	elseif dataArr[1].status == -1 then
		ngx.say(errInfo.e4);
		return false;
	elseif dataArr[1].status == 0 then
		ngx.say(errInfo.e5);
		return false;
	end


	-- 验证 userInfo 前后台用户

	local userInfoQuery = userType == 'f' and ' level = 5 ' or (userType == 'a' and ' level > 0 AND level < 5 ' or ' level = 0 ');

	sql = "SELECT 1 FROM " .. corpPinyinName  .. "_user_info WHERE user_id = " .. dataArr[1].id .. " AND " .. userInfoQuery;
	
	local uinfo = self:query(sql);
	
	if uinfo == nil then
		ngx.say(errInfo.e2);
		return false;
	end

	-- 正常登录后，清除登录失败状态
	if dataArr[1].fail_times > 0 or dataArr[1].limit_login == 1 then
		sql = "UPDATE " .. corpPinyinName  .. "_user SET limit_login = 0, fail_times = 0 WHERE id = " .. dataArr[1].id;
		self:query(sql);
	end

	-- 更新最后登录时间
	sql = "	UPDATE " .. corpPinyinName  .. "_user_info SET login_time = NOW(),ip = '" .. self:getIp() .. "' WHERE user_id = " .. dataArr[1].id ;
	self:query(sql);



	-- 查询当前公司的登录方式  sessType 1 为 redis 保存session
	local sql = "SELECT *,INET_NTOA(redis_host) as rhost FROM corp_sess_db WHERE corp_id = " .. tonumber(args.cid);
	sessDataArr = self:query(sql);

	if sessDataArr ~= nil and sessDataArr ~= false and sessDataArr[1]['isuse'] == 1 then
		sessType = 1;
	end
	-- end

	local ukey = '';
	if sessType == nil then
		-- 登录验证成功 -> 生成令牌
		sql = "	SELECT  UNIX_TIMESTAMP() AS unixtime " ;
		local unixtime = self:query(sql);
		local expire = self.ukeyLifeTime + unixtime[1].unixtime;
		-- local ukey = self:enCode(args.cid .. '_' .. dataArr[1].id, dataArr[1].id .. '|' .. args.cid .. '|' .. corpPinyinName .. '|' .. corpFlag, (self.lifeTime + ngx.time() + (3600*24)) );
		ukey = self:enCode(args.cid .. '_' .. dataArr[1].id,'', expire);
		local userData = args.cid .. '|' .. dataArr[1].id .. '|' .. corpPinyinName .. '|' .. corpFlag .. '|' .. args.cname;
		sql = "REPLACE INTO user_key(corp_id, user_id, ukey, user_data, expire) VALUES('" .. args.cid .. "','" .. dataArr[1].id .. "','" .. ukey .. "','" .. userData .. "','" .. expire .. "')";
		self:query(sql);
	end
	-- 登录日志 
	local loginLogs  = '';
	local h = ngx.req.get_headers();
	for k, v in pairs(h) do
		loginLogs = loginLogs .. k .. ":" .. v .. "  \n  ";
	end

	sql = "INSERT INTO `" .. corpPinyinName  .. "_login_log` ( `user_id`, `sess_id`, `ukey`, `data`, `status`, `ip`) VALUES ( '" .. dataArr[1].id .. "', '', '" .. ukey .. "', '" .. loginLogs .. "', '1', inet_aton('" .. self:getIp() .. "'))";
	self:query(sql);
	if sessType == nil then
		loginUrl = webUrl .. corpFlag  .. '/login/' .. args.cid .. '_' .. dataArr[1].id  .. '_' .. ukey .. '/k'; -- k 避免 nginx 规则 a|c|f 冲突
		ngx.say(loginUrl);
	else
		self:saveSession(sessType, args.cid, dataArr[1].id, corpPinyinName, corpFlag, args.cname, userType, sessDataArr);
	end

end
-- 取用户的所有上级id
function Auth:getParents(cropId,uid,parentId,level,corpPinyinName)
	local json=require "cjson"
	if(level==0) then
		return '';
	end;
	local sql='SELECT  pui.level  FROM `'..corpPinyinName..'_user_info` ui left join `'..corpPinyinName..'_user_info` pui on ui.parent_id = pui.user_id  WHERE  ui.user_id = '..uid
	local data=self:query(sql)
	if data==nil then
		return parentId
	end
	local level=data[1].level
	
	-- 公司级用户，上线是自己
	if level==0 then 
		return '1'
	end;

	local fields='su1.parent_id AS p0, su2.parent_id AS p1'
	local where=corpPinyinName..'_user_info AS su1 JOIN ' ..corpPinyinName..'_user AS ssu1 ON ssu1.id = su1.user_id JOIN '.. corpPinyinName .. '_user_info AS su2 ON su1.user_id = su2.parent_id JOIN '..corpPinyinName.. '_user AS ssu2 ON ssu2.id = su2.user_id AND ssu1.status < 4 AND ssu2.status < 4  '

	if level==4 then
		fields=fields..',su3.parent_id AS p2,su4.parent_id AS p3,su5.parent_id AS p4'
        where=where..' JOIN ' ..corpPinyinName.. '_user_info AS su3 ON su2.user_id = su3.parent_id JOIN ' ..corpPinyinName.. '_user_info AS su4 ON su3.user_id = su4.parent_id JOIN ' ..corpPinyinName.. '_user_info AS su5 ON su4.user_id = su5.parent_id JOIN ' ..corpPinyinName.. '_user AS ssu5 ON ssu5.id = su5.user_id AND ssu5.status < 4  AND su5.user_id =  ' ..uid
    elseif level==3 then
		fields =fields..',su3.parent_id AS p2,su4.parent_id AS p3'
   		where=where..' JOIN ' ..corpPinyinName.. '_user_info AS su3 ON su2.user_id = su3.parent_id JOIN ' ..corpPinyinName.. '_user_info AS su4 ON su3.user_id = su4.parent_id JOIN ' ..corpPinyinName.. '_user AS ssu4 ON ssu4.id = su4.user_id AND ssu4.status < 4  AND su4.user_id =  ' ..uid
	elseif level==2 then
		fields = fields..',su3.parent_id AS p2'
        where = where..' JOIN ' ..corpPinyinName.. '_user_info AS su3 ON su2.user_id = su3.parent_id JOIN ' ..corpPinyinName.. '_user AS ssu3 ON ssu3.id = su3.user_id AND ssu3.status < 4 AND su3.user_id =  ' ..uid
	else
		where=where..' AND su2.user_id=' ..uid
	end;
	sql='SELECT '..fields..	' FROM ' ..where;
	local parents=self:query(sql)
	
	if(parents==nil or parents[1]==nil) then
		return '1'
	end;
	parents=parents[1]
	local a={}
	for n in pairs(parents) do table.insert(a,n) end
	table.sort(a)
	local ret='';
	for n,v in ipairs(a) do
		ret=ret..parents[v]..','
	end;
	-- ret=ret..parentId
	ret=string.sub(ret,1,-2)
	return ret
end

-- 保存session：1 为 redis
function Auth:saveSession(sessType, corpId, userId, corpPinyinName, corpFlag, corpName, userType, sessDataArr)
	
-- ngx.say(sessType ..'-'.. userId..'-'..corpPinyinName..'-'..corpFlag..'-'..corpName..'-'..userType);
	local json = require "cjson"

	local dataArr = self:getUserInfo(corpPinyinName, userId, 1);
	local userInfo = dataArr[1];
	local mobiLogin = 0;
	if ngx.re.match(ngx.var.HTTP_REFERER, "mobi") ~= nil then 
		mobiLogin = 1;
	end

	
	local userInfoArr = {};
	userInfoArr.userInfo = userInfo;
	userInfoArr.corpFlag = corpFlag;
	userInfoArr.corpID = corpId;
	userInfoArr.corpName = corpName;
	userInfoArr.userType = userType;
	userInfoArr.mobiLogin = mobiLogin;

		-- test debug
	local json = require "cjson";
	userInfo.parents=Auth:getParents(corpId,userId,userInfo.parent_id,userInfo.level,corpPinyinName);

	local sessionId = ngx.md5(corpId ..'|' .. userId .. '|' ..self:getIp() .. ngx.now());

	-- 取10位做为SESSIONID
	sessionId = string.sub(sessionId, 2, 11);
	
	-- local sql = "SELECT *,INET_NTOA(redis_host) as rhost FROM corp_sess_db WHERE corp_id = " .. corpId;
	-- sessDataArr = self:query(sql);

	if sessDataArr == nil or sessDataArr == false then
		ngx.say('系统出错，请联系管理员。'); -- 
		ngx.log(ngx.ERR, '连不上DB或是没有公司的redis的配制信息, 公司ID' .. corpId .. ': 会员ID:' .. userId);
		ngx.exit(ngx.HTTP_OK);
	end
	-- 设置公司所用到的redis DB
	self.redisDb = sessDataArr[1]['redis_db'];
	self.redisDbIP = sessDataArr[1]['rhost'] .. ':' .. sessDataArr[1]['redis_port'];
	-- 设置SESSION
	self:redisSet(self.redisDb, 'sess_' .. userId, json.encode(userInfoArr), self.redisDbLifeTime);

	-- 清除COOKIE
	local path = '/' .. corpFlag .. '_' .. userId .. '/';
	local corpPath = '/' .. corpFlag .. '/';
	local expiretime = ngx.cookie_time(ngx.time()  - 3000);
	local cookieArr = {};
	table.insert(cookieArr, "sysinfo=0; expires=" ..expiretime .. ";path=" .. path);
	-- 设置 SESSION ID
	table.insert(cookieArr, "PHPSESSID=" .. sessionId  .. '_' .. corpId ..'_'..userId.."; path=" .. path);
	table.insert(cookieArr, "PHPSESSID=" .. sessionId  .. '_' .. corpId ..'_'..userId.."; path=" .. corpPath);
	ngx.header["Set-Cookie"] = cookieArr;
	ngx.say(path);
	-- 跳转页面


	loginUrl = webUrl .. corpFlag  .. '/login/' .. sessionId .. '_rdsess/k'; -- k 避免 nginx 规则 a|c|f 冲突
	
	
	ngx.say(loginUrl);

	local loginLogs  = '';
	local h = ngx.req.get_headers();
	for k, v in pairs(h) do
		loginLogs = loginLogs .. k .. ":" .. v .. "  \n  ";
	end

	sql = "INSERT INTO `" .. corpPinyinName  .. "_login_log` ( `user_id`, `sess_id`, `ukey`, `data`, `status`, `ip`) VALUES ( '" .. userId .. "', '" .. sessionId .. "', 'rdsess', '', '0', inet_aton('" .. self:getIp() .. "'))";
	self:query(sql);



end

-- 取得用户登录信息
function Auth:getLoginInfo()



	ngx.req.read_body();
	local args = ngx.req.get_post_args();
	if args.ukey == nil then
		ngx.say(-1);
		return false;
	end

	local ukeyArr = self:strSplit(args.ukey, '_');

	if table.getn(ukeyArr) < 3 then 
		ngx.say(-1);
		return false;
	end

	sql = "SELECT user_data FROM `user_key` WHERE corp_id = '" .. ukeyArr[1] .. "' AND user_id = '" .. ukeyArr[2] .. "' AND ukey = '" .. ukeyArr[3] .. "' AND UNIX_TIMESTAMP() < expire ";
	local dataArr = self:query(sql);
	
	if dataArr ~= nil then
		local userDataArr = self:strSplit(dataArr[1].user_data, '|');
		local _say = dataArr[1].user_data;
		-- 登录日志 
		local sql = 'select pinyin_name,status from corporation where id = '..tonumber(ukeyArr[1]);
		local dataArr = self:query(sql);


		if args.ip ~= nil then
			sql = "	UPDATE " .. dataArr[1].pinyin_name  .. "_user_info SET ip = '" .. args.ip .. "' WHERE user_id = " .. ukeyArr[2] ;
			self:query(sql);
		end
		
		ngx.say(_say .. '~|~' .. self:getUserInfo(userDataArr[3], userDataArr[2]) .. '~|~');

		local loginLogs  = '';
		local h = ngx.req.get_headers();
		for k, v in pairs(h) do
			loginLogs = loginLogs .. k .. ":" .. v .. "  \n  ";
		end

		sql = "INSERT INTO `" .. dataArr[1].pinyin_name  .. "_login_log` ( `user_id`, `sess_id`, `ukey`, `data`, `status`, `ip`) VALUES ( '" .. ukeyArr[2] .. "', '', '" .. ukeyArr[3] .. "', '" .. loginLogs .. "', '0', inet_aton('" .. self:getIp() .. "'))";
		self:query(sql);
		-- 清除用户的登录信息
		sql = "DELETE FROM user_key WHERE corp_id = '" .. ukeyArr[1] .. "' and  user_id = '" .. ukeyArr[2] .. "'";
		self:query(sql);

	else
		ngx.say(-1);
	end


end

-- 清除用户的登录信息
function Auth:delLoginInfo()


	ngx.req.read_body();
	local args = ngx.req.get_post_args();

	if args.cid ~= nil or args.uid ~= nil then
		sql = "DELETE FROM user_key WHERE corp_id = '" .. args.cid .. "' and  user_id = '" .. args.uid .. "'";
		self:query(sql);
		ngx.say(1);
	else
		ngx.say(-1);
	end

end

-- 取得登录后的用户信息 type 为空时返回JSON字符串
function Auth:getUserInfo(crop, uid, type)
	-- share_up_sum、share_self 属无用数据。1.2.6发完后，要去掉。
	sql = "SELECT *,0 as share_up_sum,0 as share_self FROM " .. crop .. "_user u LEFT JOIN " .. crop .. "_user_info ui ON ui.user_id = u.id WHERE u.id = " .. tonumber(uid);
	local dataArr = '';
	if type == nil then
		dataArr = self:query(sql,1);
	else
		dataArr = self:query(sql);
	end
	if dataArr ~= nil then
		return dataArr;
	else
		return -1;
	end


end




-- HUB -----------------start--



function Auth:hubvCode()

	ngx.req.read_body();
	local args = ngx.req.get_post_args();

	if args.password == nil or args.__name == nil then
		ngx.say(self.errCodeHub.e0);
		return false;
	end

	sql = "SELECT 1";

	dataArr = self:query(sql);
	if dataArr == nil then
		ngx.say(self.errCodeHub.e3);
		return false;
	end

	sql = "SELECT * FROM admin WHERE accout = '" .. args.__name .. "'";

	dataArr = self:query(sql);


	if dataArr == nil or dataArr[1].status == 4 then
		ngx.say(self.errCodeHub.e0);
		return false;
	elseif dataArr[1].status == 0 then
		ngx.say(self.errCodeHub.e2);
		return false;
	elseif dataArr[1].password ~=  ngx.md5(args.password) then


		if dataArr[1].try_count + 1 >= 5 then
			sql = "UPDATE admin SET status = 0,try_count = 0 WHERE id = " .. dataArr[1].id;
			ngx.say(self.errCodeHub.e1);
		else
			sql = "UPDATE admin SET try_count = try_count + 1 WHERE id = " .. dataArr[1].id;
			ngx.say(self.errCodeHub.e0);
		end
		
		self:query(sql);
		return false;
	end


	-- 更新登录失败次数
	if dataArr[1].try_count > 0 then
		sql = "UPDATE admin SET try_count = 0 WHERE id = " .. dataArr[1].id;
		self:query(sql);
	end

	-- 更新最后登录时间
	sql = "	UPDATE admin SET login_time = NOW() WHERE id = " .. dataArr[1].id ;
	self:query(sql);

	-- 登录验证成功 -> 生成令牌
	sql = "	SELECT  UNIX_TIMESTAMP() AS unixtime " ;
	local unixtime = self:query(sql);
	local expire = self.ukeyLifeTime + unixtime[1].unixtime;
	-- local ukey = self:enCode(dataArr[1].id, dataArr[1].id .. '|' .. ngx.time(), expire);
	local ukey = self:enCode(dataArr[1].id, '', expire);

	sql = "REPLACE INTO admin_key(user_id, ukey, expire) VALUES('" .. dataArr[1].id .. "','" .. ukey .. "','" .. expire .. "')";
	self:query(sql);

	loginUrl = hubUrl .. 'login/index/u/' .. dataArr[1].id .. '_' .. ukey .. '/k'; -- k 避免 nginx 规则 a|c|f 冲突;
	ngx.say(loginUrl);

end

function Auth:getHubLoginInfo()



	ngx.req.read_body();
	local args = ngx.req.get_post_args();
	if args.ukey == nil then
		ngx.say(-1);
		return false;
	end
	local ukeyArr = self:strSplit(args.ukey, '_');
	
	if table.getn(ukeyArr) < 2 then 
		ngx.say(-1);
		return false;
	end

	sql = "SELECT user_id FROM `admin_key` WHERE user_id = '" .. ukeyArr[1] .. "' AND ukey = '" .. ukeyArr[2] .. "' AND UNIX_TIMESTAMP() < expire ";
	local dataArr = self:query(sql);
	
	if dataArr ~= nil then
		ngx.say(dataArr[1].user_id .. '~|~' .. self:getHubUserInfo(dataArr[1].user_id));
		-- 清除用户的登录信息
		sql = "DELETE FROM admin_key WHERE user_id = '" .. dataArr[1].user_id .. "'";
		self:query(sql);
	else
		ngx.say(-1);
	end

end

function Auth:delHubLoginInfo()

	ngx.req.read_body();
	local args = ngx.req.get_post_args();
	
	if args.uid ~= nil then
		sql = "DELETE FROM admin_key WHERE user_id = '" .. args.uid .. "'";
		self:query(sql);
		ngx.say(1);
	else
		ngx.say(-1);
	end

end

function Auth:getHubUserInfo(uid)


	sql = "SELECT * FROM `admin` WHERE id = " .. tonumber(uid);
	local dataArr = self:query(sql,1);
	
	if dataArr ~= nil then
	
		return dataArr;
	else
		return -1;
	end


end


function Auth:getIp()
	-- local ip = ngx.req.get_headers()['X-Real-IP'] ~= nil and ngx.req.get_headers()['X-Real-IP'] or ngx.req.get_headers()['X-Forwarded-For'];
	local ip = ngx.req.get_headers()['X-Real-IP'] ~= nil and ngx.req.get_headers()['X-Real-IP'] or ngx.req.get_headers()['X-Forwarded-For'];
	return ip ~= nil and ip or ngx.var.remote_addr;
end
-- HUB -----------------end--






-- 显示验证码
function Auth:vImg()
 	local args = ngx.req.get_uri_args();
	if args.t == nil then
		ngx.exit(ngx.HTTP_FORBIDDEN);
	end

	vcodeConfig = self:getCodeConfig();

	local imgName = vcodeConfig.vcode[vcodeConfig.codeKey[args.t]];
	if imgName == false then
		ngx.exit(ngx.HTTP_FORBIDDEN);
	else
		local imgPath = luaPath .. 'vcode/img/' .. imgName;
		local f = assert(io.open(imgPath, "r"));
		local t = f:read("*all");
		f:close();
		ngx.header.content_type = 'image/JPEG';
		ngx.say(t);
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


function Auth:redisTest()
	--Auth:redis("foo", "grtetdg");

	--Auth:redis("foo");

	self:redisTest2();

end


function Auth:redis(k, v)
	
	
	local servers = {'redis-a', 'redis-b'}
	local i = ngx.time() % #servers + 1;
	local srv = servers[i];


	local argsTable = {
		key = k,
	        backend = srv
	      }

	local url = v == nil and '/redisGet/' or '/redisSet/';
	if v ~= nil then
		argsTable.value = v;
	end

	local res = ngx.location.capture(url,{args = argsTable});

	ngx.say(res.body)

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


function Auth:write(str)
	if str ~= nil then
		local imgPath = luaPath .. '../../logs/lua.log';
		local f = assert(io.open(imgPath, "a"));
		f:write(str);
		f:close();
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
			ngx.log(ngx.INFO,'redisSet:' .. key .. ':' .. value  .. ' ;expire:' .. expire  .. ' -- errInfo:'.. result[1]);
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
		ngx.log(ngx.INFO,'redisGet:' .. key .. ' --- 取不到数据');
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
			ngx.log(ngx.INFO,'redisRpush:' .. key .. ':' .. value  .. ' -- errInfo:'.. result[1]);
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
		ip = self.redisDbIP,
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
