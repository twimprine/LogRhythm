#
# Cookbook:: LogRhythm
# Recipe:: _windows
#
# The MIT License (MIT)
#
# Copyright:: 2017, Thomas Wimprine
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# "LogRhythm System Monitor Service"

directory 'C:/temp' do
    action :create
end

case node['kernel']['machine']
when 'i386'
    remote_file 'C:/temp/LRSystemMonitor.exe' do
      action :create
      source 'http://10.80.24.10:9000/software/logrhythm/LRSystemMonitor_7.2.6.8002.exe?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=access%2F20171206%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20171206T003113Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a2a02fba7b56a50722341813b80f4756dfdfee9599b8dfb83935611f83579cb7'
      #source '\\\\xulanas01.xula.local\\VMwareRepository\\_Software\\LogRhythm\\LRSystemMonitor_7.2.6.8002.exe'
      show_progress true
    end
else
    remote_file 'C:/temp/LRSystemMonitor.exe' do
      action :create
      source 'http://10.80.24.10:9000/software/logrhythm/LRSystemMonitor_64_7.2.6.8002.exe?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=access%2F20171206%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20171206T002310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=df4e0ae6d63532108f486592c2777ee74cd2e35b901ef3a9c20fa1e63b4672fb'
      #source '\\\\xulanas01.xula.local\\VMwareRepository\\_Software\\LogRhythm\\LRSystemMonitor_64_7.2.6.8002.exe'
      show_progress true
    end
end

windows_package 'LogRhythm System Monitor Service' do
  source 'C:\temp\LRSystemMonitor.exe'   
  installer_type :custom
  action :install
  options '/v /s'
end

template 'C:\\Program Files\\LogRhythm\\LogRhythm System Monitor\\config\\scsm.ini' do
    source 'scsm.ini.erb'
    variables({
        LogRhythm_Server: node['LogRhythmServer']
    })
end

service 'scsm' do
    subscribes :restart, 'template[C:\\Program Files\\LogRhythm\\LogRhythm System Monitor\\config\\scsm.ini]', :immediately
end    