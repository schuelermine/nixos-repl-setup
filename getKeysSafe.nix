with builtins;
#Picks out keys from a set but doesn’t throw if keys are missing
#Also allows picking keys by key lists (navigating a path)
#Also allows renaming a key, you do [ name [ ...path ] ]
set: keys:
if !isAttrs set || !isList keys then { } else
let
  lastNull = list:
    if list == [ ] then null
    else if tail list == [ ] then head list
    else lastNull (tail list);
  getByPath = set: path:
    if !isList path
    then set.${path} or (throw "Missing key")
    else if path == [ ]
    then set
    else getByPath set.${head path} or (throw "Missing key") (tail path);
  lastNullOrVal = val: if !isList val then val else lastNull val;
  getSetForKey = key:
    let
      isKVPair = isList key && length key == 2 && isList (elemAt key 1);
      path = if isKVPair then elemAt key 1 else key;
      name = if isKVPair then elemAt key 0 else lastNullOrVal key;
      attempt = tryEval (getByPath set path);
    in
    {
      ${if attempt.success then name else null} = attempt.value;
    };
  #Returns empty attrset if key isn’t present
  #Also allows renaming paths if it’s in the for [ name path@[...] ]
  merge = s1: s2: s1 // s2; #Merge two attrsets
in
foldl' merge { } (map getSetForKey keys) #Merge all attrsets incl. empty ones for missing keys
