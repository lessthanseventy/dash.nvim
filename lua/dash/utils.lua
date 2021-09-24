local M = {}

local cliPath = '/Applications/Dash.app/Contents/Resources/dashAlfredWorkflow'

function M.runSearch(query)
  local Job = require('plenary.job')
  local stdout = nil
  local stderr = nil
  Job
    :new({
      command = cliPath,
      args = { query },
      cwd = vim.fn.getcwd(),
      enabled_recording = true,
      on_exit = function(j, return_val)
        if return_val .. '' == '0' then
          stdout = j:result()
        else
          stderr = j:result()
        end
      end,
    })
    :sync()

  return {
    stdout = M.trimTrailingNewlines(M.joinListToString(stdout)),
    stderr = M.trimTrailingNewlines(M.joinListToString(stderr)),
  }
end

local char_to_hex = function(c)
  return string.format('%%%02X', string.byte(c))
end

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub('\n', '\r\n')
  url = string.gsub(url, '([^%w _ %- . ~])', char_to_hex)
  url = url:gsub(' ', '+')
  return url
end

function M.openQuery(query)
  local Job = require('plenary.job')

  Job
    :new({
      command = 'open',
      args = { '-g', ('dash-workflow-callback://' .. urlencode(query)) },
    })
    :start()
end

function M.joinListToString(output)
  if not (type(output) == 'table') then
    return output
  end

  local str = ''
  for _, val in pairs(output) do
    str = str .. val .. '\n'
  end
  return str
end

function M.trimTrailingNewlines(str)
  if str == nil then
    return nil
  end
  local n = #str
  while n > 0 and str:find('^%s', n) do
    n = n - 1
  end
  return str:sub(1, n)
end

return M
