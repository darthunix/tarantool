local server = require('test.luatest_helpers.server')
local t = require('luatest')
local g = t.group()

g.before_test('test_with_option', function()
    g.server = server:new({alias = 'with_option',
                            box_cfg = {log_print_module_name=true}})
    g.server:start()
end)

g.after_test("test_with_option", function()
    g.server:drop()
end)

local function module_name_is_in_logs()
    g.server:exec(function()
        local t = require('luatest')
        testmod = require('testmod')
        testmod.make_logs()
    end)
    t.helpers.retrying({timeout = 1, delay = 0.1}, function()
        local msg = "/testmod I> info message form testmod"
        t.assert(g.server:grep_log(msg))
    end)
end

g.test_with_option = module_name_is_in_logs

g.before_test('test_without_option', function()
    g.server = server:new({alias = 'without_option'})
    g.server:start()
end)

g.after_test("test_without_option", function()
    g.server:drop()
end)

g.test_without_option = function()
    t.xfail('Must fail because log_print_module_name=false by default')
    module_name_is_in_logs()
end

g.before_test('test_is_local_for_each_module', function()
    g.server = server:new({alias = 'with_option',
                           box_cfg = {log_print_module_name=true}})
    g.server:start()
end)

g.after_test("test_is_local_for_each_module", function()
    g.server:drop()
end)

g.test_is_local_for_each_module = function()
    g.server:exec(function()
        local t = require('luatest')
        testmod = require('testmod')
        testmod3 = require('testmod3')
        testmod3.make_logs()
        testmod.make_logs()
    end)
    t.helpers.retrying({timeout = 1, delay = 0.1}, function()
        local msg = "/testmod I> info message form testmod"
        t.assert(g.server:grep_log(msg))
    end)
end


g.before_test('test_module_with_other_modules', function()
    g.server = server:new({alias = 'with_option',
                           box_cfg = {log_print_module_name=true}})
    g.server:start()
end)

g.after_test("test_module_with_other_modules", function()
    g.server:drop()
end)

g.test_module_with_other_modules = function()
    g.server:exec(function()
        local t = require('luatest')
        testmod2 = require('testmod2')
        testmod2.make_logs()
    end)
    t.helpers.retrying({timeout = 1, delay = 0.1}, function()
        local msg = "/testmod2 I> info message form testmod2"
        t.assert(g.server:grep_log(msg))
    end)
    t.helpers.retrying({timeout = 1, delay = 0.1}, function()
        local msg = "/testmod I> info message form testmod"
        t.assert(g.server:grep_log(msg))
    end)
end
