task :lint do
  sh "buedle exec standardrb ./src/**/*.rb ./tests/**/*.rb"
end

task :lint_fix do
  sh "bundle exec standardrb --fix ./src/**/*.rb ./tests/**/*.rb"
end

task :test do
  sh "bundle exec ruby ./tests/*.rb"
end
