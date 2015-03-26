
unless node['et_ntp']['pool'].empty?
  node.default['ntp']['servers'] = node['et_ntp']['pool']
  node.default['ntp']['server']['prefer'] = node['et_ntp']['master']
end
