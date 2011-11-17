require 'rubygems'
require 'closure-compiler'

HEADER = /((^\s*\/\/.*\n)+)/
def minimize_with_header(source_filename, destination_filename)
  source  = File.read(source_filename)
  header  = source.match(HEADER)
  min     = Closure::Compiler.new.compress(source)
  File.open(destination_filename, 'w') do |file|
    file.write header[1].squeeze(' ') + min
  end
end

# Check for the existence of an executable.
def check(exec, name, url)
  return unless `which #{exec}`.empty?
  puts "#{name} not found.\nInstall it from #{url}"
  exit
end

desc "Use the Closure Compiler to compress Lifecycle.js"
task :build do
  minimize_with_header('lifecycle.js', 'lifecycle-min.js')
end

desc "check, build and generate documentation"
task :package do
  begin
    system "jsl -nofilelisting -nologo -conf docs/jsl.conf -process lifecycle.js"
    minimize_with_header('lifecycle.js', 'lifecycle-min.js')
    check 'docco', 'docco', 'https://github.com/jashkenas/docco'
    sh "docco lifecycle.js"
  end
end

desc "Build the docco documentation"
task :doc do
  check 'docco', 'docco', 'https://github.com/jashkenas/docco'
  sh "docco lifecycle.js"
end

desc "run JavaScriptLint on the source"
task :lint do
  system "jsl -nofilelisting -nologo -conf docs/jsl.conf -process lifecycle.js"
end
