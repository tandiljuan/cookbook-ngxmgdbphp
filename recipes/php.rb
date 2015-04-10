#
# Cookbook Name:: cookbook-ngxmgdbpy
# Recipe:: php
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

# On Ubuntu 14.04 (Trusty Tahr) the default version is 5.5.9
%w( php5-fpm ).each do |pkg|
  package pkg
end

# PHP FPM INI configuration file
template "/etc/php5/fpm/php.ini" do
  source "php/php.ini.erb"
  owner node[:core][:user]
  group node[:core][:group]
  mode 00664
  variables({
    :memory_limit => node[:cookbook][:php][:memory_limit],
    :error_reporting => node[:cookbook][:php][:error_reporting],
    :display_errors => node[:cookbook][:php][:display_errors],
    :display_startup_errors => node[:cookbook][:php][:display_startup_errors],
    :post_max_size => node[:cookbook][:php][:post_max_size],
    :file_uploads => node[:cookbook][:php][:file_uploads],
    :upload_max_filesize => node[:cookbook][:php][:upload_max_filesize],
    :max_file_uploads => node[:cookbook][:php][:max_file_uploads],
    :session_use_cookies => node[:cookbook][:php][:session][:use_cookies],
    :session_name => node[:cookbook][:php][:session][:name],
    :opcache_enable => node[:cookbook][:php][:opcache][:enable],
    :opcache_enable_cli => node[:cookbook][:php][:opcache][:enable_cli],
    :opcache_memory_consumption => node[:cookbook][:php][:opcache][:memory_consumption],
    :opcache_interned_strings_buffer => node[:cookbook][:php][:opcache][:interned_strings_buffer],
    :opcache_max_accelerated_files => node[:cookbook][:php][:opcache][:max_accelerated_files],
    :opcache_revalidate_freq => node[:cookbook][:php][:opcache][:revalidate_freq],
    :opcache_save_comments => node[:cookbook][:php][:opcache][:save_comments],
    :opcache_fast_shutdown => node[:cookbook][:php][:opcache][:fast_shutdown],
  })
  action :create
end

# PHP Pool file
template File.join(["/etc/php5/fpm/pool.d", "#{node[:core][:project_name]}.conf"]) do
  source "php/pool.conf.erb"
  owner node[:core][:user]
  group node[:core][:group]
  mode 00664
  variables({
    :app_name => node[:core][:project_name],
    :user => node[:cookbook][:php][:fpm][:user],
    :group => node[:cookbook][:php][:fpm][:group],
    :listen => node[:cookbook][:php][:fpm][:listen],
    :listen_backlog => node[:cookbook][:php][:fpm][:listen_backlog],
  })
  action :create
end

# Enable PHP service
service "php" do
  service_name "php5-fpm"
  supports :reload => true, :restart => true, :start => true, :status => true, :stop => true
  action [:enable, :restart]
end

