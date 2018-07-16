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
      source 'https://s3.amazonaws.com/docs.xula.local/LogRythm/LRSystemMonitor_7.3.2.8000.exe'
      #source '\\\\xulanas01.xula.local\\VMwareRepository\\_Software\\LogRhythm\\LRSystemMonitor_7.2.6.8002.exe'
      show_progress true
    end
else
    remote_file 'C:/temp/LRSystemMonitor.exe' do
      action :create
      source 'https://s3.amazonaws.com/docs.xula.local/LogRythm/LRSystemMonitor_64_7.3.2.8000.exe'
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

windows_service 'scsm' do
  action :start
  action :enables
end
