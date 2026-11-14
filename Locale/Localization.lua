local LOCALE = GetLocale()
-- missing translations fall back to the English key.  (The old version called
-- ArchiTotem_Print here, which does not exist yet while this file loads, so
-- non-English clients got an error.)
ArchiTotemLocale = setmetatable({},{__index = function(t,k)
  local v = tostring(k)
  rawset(t,k,v)
  if (LOCALE ~= "enUS") and (LOCALE ~= "enGB") and ArchiTotem_Print
     and ArchiTotem_Options and ArchiTotem_Options.Debug then
    ArchiTotem_Print(string.format(" %q not found for %s",v,LOCALE),"debug")
  end
  return v
end})
-- key binding names are set in ArchiTotem.lua, after the translations
