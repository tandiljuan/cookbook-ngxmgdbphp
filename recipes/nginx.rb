#
# Cookbook Name:: cookbook-ngxmgdbpy
# Recipe:: nginx
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

include_recipe "nginx"

# Set Nginx Basic Authentication
# @see http://httpd.apache.org/docs/2.2/misc/password_encryptions.html#basic
if node[:cookbook][:nginx][:auth][:enabled]
    require 'digest/sha1'
    require 'base64'

    auth_content = ''

    node[:cookbook][:nginx][:auth][:credentials].each do |credential|
        auth_content += "#{credential[:user]}:{SHA}" + Base64.encode64(Digest::SHA1.digest(credential[:pass]))
    end

    file '/etc/nginx/htpasswd' do
        owner node[:core][:user]
        group node[:core][:group]
        mode 00664
        content auth_content
    end
end

# Set Nginx configuration
template "/etc/nginx/nginx.conf" do
  source "nginx/nginx.conf.erb"
  owner node[:core][:user]
  group node[:core][:group]
  mode 00664
  variables({
    :user => node[:core][:user],
  })
  action :create
  notifies :restart, "service[nginx]"
end

# Create Nginx site configuration
template ::File.join(["/etc/nginx/sites-available", node[:core][:project_name]]) do
  source "nginx/default.erb"
  owner node[:core][:user]
  group node[:core][:group]
  mode 00664
  variables({
    :app_name => node[:core][:project_name],
    :listen_port => node[:nginx][:listen_port],
    :server_name => node[:nginx][:server_name],
    :logdir => node['nginx']['log_dir'],
    :php_fpm => node[:cookbook][:php][:fpm][:listen],
    :root => node[:cookbook][:nginx][:root],
    :max_body_size => node[:cookbook][:nginx][:max_body_size],
    :body_buffer_size => node[:cookbook][:nginx][:body_buffer_size],
  })
  action :create
  notifies :restart, "service[nginx]"
end

# Enable Nginx site
link ::File.join(["/etc/nginx/sites-enabled", node[:core][:project_name]]) do
  to ::File.join(["/etc/nginx/sites-available", node[:core][:project_name]])
  owner node[:core][:user]
  group node[:core][:group]
  action :create
end

