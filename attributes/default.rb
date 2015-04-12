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

# PHP Settings
default[:cookbook][:php][:memory_limit] = "128M"
default[:cookbook][:php][:error_reporting] = "E_ALL & ~E_DEPRECATED & ~E_STRICT"
default[:cookbook][:php][:display_errors] = true
default[:cookbook][:php][:display_startup_errors] = true
default[:cookbook][:php][:post_max_size] = "8M"
default[:cookbook][:php][:file_uploads] = true
default[:cookbook][:php][:upload_max_filesize] = "2M"
default[:cookbook][:php][:max_file_uploads] = 20 # Mega

default[:cookbook][:php][:session][:use_cookies] = true
default[:cookbook][:php][:session][:name] = "PHPSESSID"

default[:cookbook][:php][:opcache][:enable] = false
default[:cookbook][:php][:opcache][:enable_cli] = false
default[:cookbook][:php][:opcache][:memory_consumption] = 128
default[:cookbook][:php][:opcache][:interned_strings_buffer] = 8
default[:cookbook][:php][:opcache][:max_accelerated_files] = 4000
default[:cookbook][:php][:opcache][:revalidate_freq] = 60
default[:cookbook][:php][:opcache][:save_comments] = true
default[:cookbook][:php][:opcache][:fast_shutdown] = true

default[:cookbook][:php][:fpm][:user] = node[:core][:user]
default[:cookbook][:php][:fpm][:group] = node[:core][:group]
default[:cookbook][:php][:fpm][:listen] = '127.0.0.1:9000'
default[:cookbook][:php][:fpm][:listen_backlog] = 65535

default[:cookbook][:php][:project][:name] = node[:core][:project_name]
default[:cookbook][:php][:project][:index] = "index.php"
default[:cookbook][:php][:project][:laravel][:version] = "5.0.22"

# Nginx Settings
default[:cookbook][:nginx][:root] = ::File.join([node[:core][:project_path], node[:cookbook][:php][:project][:name], "public"])
default[:cookbook][:nginx][:max_body_size] = "#{node[:cookbook][:php][:max_file_uploads]}m"
default[:cookbook][:nginx][:body_buffer_size] = "128k"

default[:nginx][:default_site_enabled] = false
default[:nginx][:listen_port]          = 80
default[:nginx][:server_name]          = node[:hostname]
override[:nginx][:user]                = node[:core][:user]
override[:nginx][:group]               = node[:core][:group]

# MongoDB Settings
default[:cookbook][:mongodb][:host]         =  "localhost"
default[:cookbook][:mongodb][:port]         =  node[:mongodb][:config][:port]
default[:cookbook][:mongodb][:ddbb]         =  "mongo_ddbb"
default[:cookbook][:mongodb][:user][:name]  =  "user"
default[:cookbook][:mongodb][:user][:pass]  =  "ZQhBV5xPdabn3gqxGMzQUJhL"
default[:cookbook][:mongodb][:admin][:name] =  "admin"
default[:cookbook][:mongodb][:admin][:pass] =  "Jp54VpQeEhcdnsstPThGk36V"

default[:mongodb][:config][:auth]    = true
default[:mongodb][:admin][:username] = node[:cookbook][:mongodb][:admin][:name]
default[:mongodb][:admin][:password] = node[:cookbook][:mongodb][:admin][:pass]
default[:mongodb][:users]            = [{
    :username => node[:cookbook][:mongodb][:user][:name],
    :password => node[:cookbook][:mongodb][:user][:pass],
    :roles => %w( readWrite dbAdmin userAdmin ),
    :database => node[:cookbook][:mongodb][:ddbb],
}]

