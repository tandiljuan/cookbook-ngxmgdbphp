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

# Install git (some modules needs to be cloned with git)
package "git"

# Create directory to be used as Composer cache
directory node[:cookbook][:php][:composer][:cache_path] do
  user node[:core][:user]
  group node[:core][:group]
  recursive true
  mode '0755'
  action :create
end

# Install Laravel, if there is no app
execute "Install Laravel (version #{node[:cookbook][:php][:project][:laravel][:version]})" do
  cwd node[:core][:project_path]
  user node[:core][:user]
  group node[:core][:group]
  command <<-SHELL
    php #{node[:composer][:bin]} \
      create-project laravel/laravel \
      --prefer-dist \
      #{node[:cookbook][:php][:project][:name]} \
      #{node[:cookbook][:php][:project][:laravel][:version]}

    chmod a+x #{node[:cookbook][:php][:project][:name]}/artisan
  SHELL
  environment ({
    "HOME" => node[:cookbook][:php][:composer][:cache_path],
  })
  action :run
  notifies :restart, "service[mongodb]"
  notifies :restart, 'service[php]'
  notifies :restart, "service[nginx]"
  only_if do
    (::Dir.entries(node[:core][:project_path]) - [".dumb"]).size <= 2
  end
end

# Create `.env` file
dot_env = ''
node[:cookbook][:laravel][:env].each do |key, value|
    dot_env += "#{key}=#{value}\n"
end

file ::File.join([node[:core][:project_path], node[:cookbook][:php][:project][:name], ".env"]) do
  content dot_env
  owner node[:core][:user]
  group node[:core][:group]
  mode 00664
end

# Update project dependencies
execute "Update project #{node[:cookbook][:php][:project][:name]} (with composer)" do
  cwd ::File.join([node[:core][:project_path], node[:cookbook][:php][:project][:name]])
  user node[:core][:user]
  group node[:core][:group]
  command <<-SHELL
    php artisan clear-compiled

    php #{node[:composer][:bin]} \
      update \
      --prefer-dist \
      --verbose

    php artisan optimize
  SHELL
  environment ({
    "HOME" => node[:cookbook][:php][:composer][:cache_path],
  })
  action :run
  timeout 1200 # 20 minutes
  ignore_failure true
  notifies :restart, "service[mongodb]"
  notifies :restart, 'service[php]'
  notifies :restart, "service[nginx]"
  only_if do
    ::File.exists?(::File.join([node[:core][:project_path], node[:cookbook][:php][:project][:name], "composer.json"]))
  end
end

