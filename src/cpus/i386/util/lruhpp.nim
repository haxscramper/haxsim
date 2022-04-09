import
  commonhpp
import
  list
import
  unordered_map
type
  LRU*[K, V] = object
    item_list*: std_list[std_pair[K, V]]
    item_map*: std_unordered_map[K, typeof(item_list.begin())]
    size*: uint16      
  
proc initLRU*(s: uint16): LRU = 
  size = s

proc exist*(this: var LRU[K, V], key: K): bool = 
  return item_map.count(key) > 0

proc put*[K, V, K, V](this: var LRU[K, V], key: K, val: V): void = 
  var it: auto = item_map.find(key)
  if it != item_map.`end`():
    item_list.erase(it.second)
    item_map.erase(it)
  
  item_list.push_front(std.make_pair(key, val))
  item_map.insert(make_pair(key, item_list.begin()))
  if item_map.size() > size:
    var it: auto = item_list.`end`()
    item_map.erase((preDec(it)).first)
    item_list.pop_back()
  

proc get*[K, V, K, V](this: var LRU[K, V], key: K): V = 
  ASSERT(exist(key))
  var it: auto = item_map[key]
  item_list.splice(item_list.begin(), item_list, it)
  return it.second
