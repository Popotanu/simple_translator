task :lint do
  sh "bundle exec standardrb ./src/*.rb"
end

task :lint_fix do
  sh "bundle exec standardrb --fix ./src/*.rb"
end

task :test do
  sh "bundle exec ruby ./tests/*.rb"
end
