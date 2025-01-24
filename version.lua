lib.versionCheck('Force-Developing/force-sling')

local latestVersionUrl =
"https://gist.githubusercontent.com/Force-Developing/ee739a3263bc3421257d901e53e27b10/raw/force-sling"
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

local function parseVersion(version)
  local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
  if not major then return nil end
  return {
    major = tonumber(major),
    minor = tonumber(minor),
    patch = tonumber(patch)
  }
end

-- Compare versions
local function isNewerVersion(current, latest)
  local currentParsed = parseVersion(current)
  local latestParsed = parseVersion(latest)

  if not currentParsed or not latestParsed then
    return false
  end

  if latestParsed.major > currentParsed.major then return true end
  if latestParsed.major < currentParsed.major then return false end
  if latestParsed.minor > currentParsed.minor then return true end
  if latestParsed.minor < currentParsed.minor then return false end
  return latestParsed.patch > currentParsed.patch
end

local function formatChangelogs(changelogs)
  if not changelogs then return "No changelog available" end
  return changelogs:gsub("%-", "\n-"):gsub("^%s*(.-)%s*$", "%1")
end

local function versionCheck()
  PerformHttpRequest(latestVersionUrl, function(err, response, headers)
    if err ~= 200 then
      lib.print.error(string.format("Version check failed with error code: %s", err))
      return
    end

    local success, result = pcall(function()
      local version, changelogs = response:match("<(.-)>(.-)<")
      if not version then
        version = response:match("<(.-)>")
        changelogs = response:match(">(.-)<")
      end

      if not version then
        error("Invalid version format in response")
      end

      version = version:gsub("[<>]", "")
      local isNewer = isNewerVersion(currentVersion, version)

      local output = string.format([[
-------------
Current Version: %s
Latest Version: %s
-------------
%s
-------------]],
        currentVersion,
        version,
        isNewer and string.format(
          "Update available!\nChangelogs:\n%s",
          formatChangelogs(changelogs)
        ) or "You are running the latest version."
      )

      if isNewer then
        lib.print.warn(output)
      else
        lib.print.info(output)
      end
    end)

    if not success then
      lib.print.error(string.format("Failed to process version check: %s", result))
    end
  end, 'GET', '', {
    ['Cache-Control'] = 'no-cache',
    ['Content-Type'] = 'application/json',
    ['User-Agent'] = string.format('force-appearance/%s', currentVersion)
  })
end

CreateThread(function()
  Wait(5000) -- Initial delay to ensure resource is fully started
  versionCheck()
end)
