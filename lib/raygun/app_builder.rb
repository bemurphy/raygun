module Raygun
  class AppBuilder < Rails::AppBuilder
    include Raygun::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def remove_public_index
      remove_file 'public/index.html'
    end

    def remove_rails_logo_image
      remove_file 'app/assets/images/rails.png'
    end

    def remove_application_layout
      remove_file 'app/views/layouts/application.html.erb'
    end

    def raise_delivery_errors
      replace_in_file 'config/environments/development.rb',
        'raise_delivery_errors = false', 'raise_delivery_errors = true'
    end

    def enable_factory_girl_syntax
      copy_file 'factory_girl_syntax_rspec.rb', 'spec/support/factory_girl.rb'
    end

    def enable_threadsafe_mode
      replace_in_file 'config/environments/production.rb',
        '# config.threadsafe!', 'config.threadsafe!'
    end

    def initialize_on_precompile
        inject_into_file 'config/application.rb',
        "\n    config.assets.initialize_on_precompile = false",
        after: 'config.assets.enabled = true'
    end

    def setup_acceptance_environment
      run 'cp config/environments/production.rb config/environments/acceptance.rb'
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    #def create_shared_flashes
    #  copy_file '_flashes.html.slim', 'app/views/application/_flashes.html.slim'
    #end

    #def create_shared_javascripts
    #  copy_file '_javascript.html.erb', 'app/views/application/_javascript.html.erb'
    #end

    def create_application_layout
      template 'application.html.slim.erb',
        'app/views/layouts/application.html.slim',
        force: true
    end

    #def create_common_javascripts
    #  directory 'javascripts', 'app/assets/javascripts'
    #end

    def use_postgres_config_template
      template 'postgresql_database.yml.erb',
               'config/database.yml',
               force: true
    end

    def create_database
      bundle_command 'exec rake db:create'
    end

    def configure_rvm
      template 'rvmrc.erb', '.rvmrc'
      # TODO Switch to the rvm ruby/gemset.
    end

    def configure_gemfile
      copy_file 'Gemfile_customized', 'Gemfile', force: true
    end

    def add_custom_gems
      additions_path = find_in_source_paths 'Gemfile_additions'
      new_gems = File.open(additions_path).read
      inject_into_file 'Gemfile', "\n#{new_gems}",
        :after => /gem 'jquery-rails'/
    end

    #def add_clearance_gem
    #  inject_into_file 'Gemfile', "\ngem 'clearance'",
    #    :after => /gem 'jquery-rails'/
    #end
    #
    #def add_capybara_webkit_gem
    #  inject_into_file 'Gemfile', "\n  gem 'capybara-webkit', '~> 0.11.0'",
    #    :after => /gem 'cucumber-rails', '1.3.0', :require => false/
    #end

    def configure_rspec
      generators_config = <<-RUBY
    config.generators do |generate|
      generate.test_framework :rspec
      generate.helper false
      generate.stylesheets false
      generate.javascript_engine false
      generate.route_specs false
    end
      RUBY
      inject_into_class 'config/application.rb', 'Application', generators_config
    end

    def generate_rspec
      generate 'rspec:install'
    end


    def configure_time_zone
      time_zone_config = <<-RUBY
          config.active_record.default_timezone = :utc
      RUBY
      inject_into_class "config/application.rb", "Application", time_zone_config
    end

    def configure_action_mailer
      action_mailer_host 'development', "#{app_name}.local"
      action_mailer_host 'test', 'example.com'
      action_mailer_host 'acceptance', "acceptance.#{app_name}.com"
      action_mailer_host 'production', "#{app_name}.com"
    end

    def setup_simple_form
      generate 'simple_form:install --bootstrap'

      replace_in_file 'config/initializers/simple_form.rb',
        %(# config.label_text = lambda { |label, required| "\#{required} \#{label}" }),
        %(config.label_text = lambda { |label, required| "\#{label}" })
    end

    def setup_sorcery
      generate 'sorcery:install'

      replace_in_file 'app/models/user.rb', /^.*# attr_accessible :title, :body$\n/, ''
    end

    #def setup_guard
    #  copy_file 'Guardfile', 'Guardfile'
    #end

    #def generate_clearance
    #  generate 'clearance:install'
    #  generate 'clearance:features'
    #end

    #def setup_stylesheets
    #  copy_file 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.css.scss'
    #  remove_file 'app/assets/stylesheets/application.css'
    #  concat_file 'import_scss_styles', 'app/assets/stylesheets/application.css.scss'
    #  create_file 'app/assets/stylesheets/_screen.scss'
    #end

    #def gitignore_files
    #  concat_file 'suspenders_gitignore', '.gitignore'
    #  ['app/models',
    #    'app/assets/images',
    #    'app/views/pages',
    #    'db/migrate',
    #    'log',
    #    'spec/support',
    #    'spec/lib',
    #    'spec/models',
    #    'spec/views',
    #    'spec/controllers',
    #    'spec/helpers',
    #    'spec/support/matchers',
    #    'spec/support/mixins',
    #    'spec/support/shared_examples'].each do |dir|
    #    empty_directory_with_gitkeep dir
    #  end
    #end

    #def init_git
    #  run 'git init'
    #end

    #def create_heroku_apps
    #  path_addition = override_path_for_tests
    #  run "#{path_addition} heroku create #{app_name}-production --remote=production"
    #  run "#{path_addition} heroku create #{app_name}-staging    --remote=staging"
    #end

    #def create_github_repo(repo_name)
    #  path_addition = override_path_for_tests
    #  run "#{path_addition} hub create #{repo_name}"
    #end

    #def copy_miscellaneous_files
    #  copy_file 'errors.rb', 'config/initializers/errors.rb'
    #  copy_file 'Procfile'
    #end

#    def customize_error_pages
#      meta_tags =<<-EOS
#  <meta charset='utf-8' />
#  <meta name='ROBOTS' content='NOODP' />
#      EOS
#      style_tags =<<-EOS
#<link href='/assets/application.css' media='all' rel='stylesheet' type='text/css' />
#      EOS
#      %w(500 404 422).each do |page|
#        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
#        replace_in_file "public/#{page}.html", /<style.+>.+<\/style>/mi, style_tags.strip
#        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
#      end
#    end

    def setup_root_route
      route "\n  root to: 'user_sessions#new'"
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb', /Application\.routes\.draw do.*end/m, "Application.routes.draw do\nend"
    end

    #def set_attr_accessibles_on_user
    #  inject_into_file 'app/models/user.rb',
    #    "  attr_accessible :email, :password\n",
    #    :after => /include Clearance::User\n/
    #end

    #def add_email_validator
    #  copy_file 'email_validator.rb', 'app/validators/email_validator.rb'
    #end

    #def include_clearance_matchers
    #  create_file 'spec/support/clearance.rb', "require 'clearance/testing'"
    #end

    #def setup_default_rake_task
    #  append_file 'Rakefile' do
    #    "task(:default).clear\ntask :default => [:spec, :cucumber]"
    #  end
    #end

    private

    #def override_path_for_tests
    #  if ENV['TESTING']
    #    support_bin = File.expand_path(File.join('..', '..', '..', 'features', 'support', 'bin'))
    #    "PATH=#{support_bin}:$PATH"
    #  end
    #end
  end
end