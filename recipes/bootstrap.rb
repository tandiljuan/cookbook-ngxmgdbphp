#
# Cookbook Name:: cookbook-ngxmgdbpy
# Recipe:: bootstrap
#
# Author:: Juan Manuel Lopez
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install composer
include_recipe "composer"

# Create a simple demo app, if there is no app
template File.join([node[:core][:project_path], node[:cookbook][:php][:project][:index]]) do
  source "php/index.php.erb"
  owner node[:core][:user]
  group node[:core][:group]
  mode 00664
  variables({
    :mongo_host => node[:cookbook][:mongodb][:host],
    :mongo_port => node[:cookbook][:mongodb][:port],
    :mongo_ddbb => node[:cookbook][:mongodb][:ddbb],
    :mongo_user => node[:cookbook][:mongodb][:user][:name],
    :mongo_pass => node[:cookbook][:mongodb][:user][:pass],
  })
  only_if do
    (::Dir.entries(node[:core][:project_path]) - [".dumb"]).size <= 2
  end
  notifies :restart, "service[mongodb]"
  notifies :restart, 'service[php]'
  notifies :restart, "service[nginx]"
end

