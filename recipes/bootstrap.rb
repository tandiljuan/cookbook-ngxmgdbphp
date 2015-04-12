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
  action :run
  notifies :restart, "service[mongodb]"
  notifies :restart, 'service[php]'
  notifies :restart, "service[nginx]"
  only_if do
    (::Dir.entries(node[:core][:project_path]) - [".dumb"]).size <= 2
  end
end

