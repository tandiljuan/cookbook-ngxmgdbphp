#
# Cookbook Name:: cookbook-ngxmgdbpy
# Attribute: default
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

#
# List of environments
# - development
#

# Override `chef_environment` variable with `chef_environment` attribute
# @see  http://stackoverflow.com/q/19905431
node.chef_environment = node[:chef_environment] if node[:chef_environment] != nil

# Core settings
default[:core][:project_name]   = "NgxMgDBPHP"

# Nginx Settings
default[:nginx][:default_site_enabled] = false
default[:nginx][:listen_port]          = 80
default[:nginx][:server_name]          = node[:hostname]
override[:nginx][:user]                = node[:core][:user]
override[:nginx][:group]               = node[:core][:group]

