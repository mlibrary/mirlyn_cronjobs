#!/l/solr-vufind/apps/jruby/bin/jruby

require 'rubygems'
require 'yaml'
require 'open-uri'
require 'pp'

rmap = YAML.load(open 'http://mirlyn-aleph.lib.umich.edu/namespacemap.yaml')

###################################
# First, we do the translation map
##################################

ht_mapfile = '/l/solr-vufind/apps/marc2solr_example/umich/translation_maps/ht_namespace_map.rb'

map = {}
rmap.keys.each {|k| map[k] = rmap[k]['desc']}

tmap = {
 :maptype=>:kv,
 :mapname=>"ht_namespace_map",
 :map => map
}

File.open(ht_mapfile, 'w') do |f|
  PP.pp tmap, f
end