namespace :provision do

  desc 'Install dependency packages'
  task :install_deps do
    on release_roles(:all) do
      execute 'apt-get', 'update'
      execute 'apt-get', 'install', '--yes', *fetch(:dep_packages)
    end
  end

  desc 'Install rbenv'
  task :install_rbenv do
    on release_roles(:all) do
      rbenv_path = fetch(:rbenv_custom_path)
      ruby_build_path = File.join(rbenv_path, 'plugins/ruby-build')

      if test("[ -d #{rbenv_path} ]")
        info 'rbenv has been installed, installed versions: '
        info capture("#{fetch(:rbenv_custom_path)}/bin/rbenv version")
        info ''
      else
        execute :git, 'clone', 'https://github.com/rbenv/rbenv.git', rbenv_path
      end

      if test("[ -d #{ruby_build_path} ]")
        info 'ruby-build has been installed'
      else
        execute :git, 'clone', 'https://github.com/rbenv/ruby-build.git', ruby_build_path
      end
    end
  end

  desc 'Update rbenv'
  task :update_rbenv do
    on release_roles(:all) do
      within fetch(:rbenv_custom_path) do
        execute :git, 'pull'
      end

      within File.join(fetch(:rbenv_custom_path), 'plugins/ruby-build') do
        execute :git, 'pull'
      end
    end
  end

  desc 'Install Ruby'
  task :install_ruby do
    gems = %w(bundler).join(' ')
    rbenv = "#{fetch(:rbenv_custom_path)}/bin/rbenv"

    on release_roles(:all) do
      with rbenv_version: fetch(:rbenv_ruby) do
        execute rbenv, 'install --skip-existing', fetch(:rbenv_ruby)
        execute rbenv, 'exec', 'gem install --no-document', gems
      end
    end
  end

  desc 'Install nvm'
  task :install_nvm do
    on release_roles(:all) do
      if test("[ -d #{fetch(:nvm_custom_path)} ]")
        info 'nvm has been installed.'
      else
        execute :git, 'clone', 'https://github.com/creationix/nvm.git', fetch(:nvm_custom_path)
      end

      within fetch(:nvm_custom_path) do
        execute :git, 'checkout', 'v0.33.2'
      end
    end
  end

  desc 'Install Node'
  task :install_node do
    node_pkgs = %w(yarn bower).join(' ')
    nvm_prefix = "source #{fetch(:nvm_custom_path)}/nvm.sh; nvm exec --silent #{fetch(:nvm_node)}"
    registry_option = ENV['TAOBAO_REGISTRY'] ? '--registry=https://registry.npm.taobao.org' : ''

    on release_roles(:all) do
      execute "source #{fetch(:nvm_custom_path)}/nvm.sh; nvm install #{fetch(:nvm_node)}"
      execute "#{nvm_prefix} npm install --global #{registry_option} #{node_pkgs}"
    end
  end

  # For the host in China, use taobao registry to download packages
  desc 'Upload .npmrc file'
  task :upload_npmrc do
    if ENV['TAOBAO_REGISTRY']
      on release_roles(:all) do
        upload!('config/deploy/templates/dot_files/.npmrc', '.npmrc')
      end
    end
  end

end

namespace :load do
  task :defaults do
    packages = %w(
      autoconf
      bison
      build-essential

      git
      nginx
      redis-server
      sqlite3
    )

    lib_packages = %w(
      libffi-dev
      libgdbm-dev
      libgdbm3
      libmysqlclient-dev
      libncurses5-dev
      libreadline6-dev
      libsqlite3-dev
      libssl-dev
      libyaml-dev
      zlib1g-dev
    )

    set :dep_packages, (packages + lib_packages)
  end
end
