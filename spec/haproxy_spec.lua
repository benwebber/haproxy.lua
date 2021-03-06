local file    = require('pl.file')
local path    = require('pl.path')
local stringx = require('pl.stringx')
local json    = require('dkjson')

local stats   = require('haproxy.stats')

local SPEC_DIR = path.abspath(path.dirname(stringx.lstrip(debug.getinfo(1, 'S').source, '@')))

local function fixture(name)
  return file.read(path.join(SPEC_DIR, 'fixtures', name))
end

describe('Client', function()
  it('initializes correctly with default values', function()
    local client = stats.Client()
    assert.equal(getmetatable(client), stats.Client)
  end)

  it('accepts socket configuration', function()
    local client = stats.Client('127.0.0.1', 8000, 1)
    assert.same(
      {
        address = '127.0.0.1',
        port    = 8000,
        timeout = 1,
      },
      client)
  end)

  it('can be initialized with _init() or new()', function()
    local client1 = stats.Client()
    local client2 = stats.Client.new()
    assert.same(client1, client2)
  end)

  it('should use LuaSocket outside of HAProxy', function()
    local client = stats.Client()
    local socket = require('socket')
    assert.same(getmetatable(client.tcp()), getmetatable(socket.tcp()))
  end)
end)

describe('stats parser', function()
  it('should parse CSV correctly', function()
    local response = fixture('stats.csv')
    local parsed = json.decode(fixture('stats.json'))
    assert.same(stats.parse_stats(response), parsed)
  end)
end)

describe('info parser', function()
  it('should parse info correctly', function()
    local response = fixture('info.txt')
    local parsed = json.decode(fixture('info.json'))
    assert.same(stats.parse_info(response), parsed)
  end)
end)
