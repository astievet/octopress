$:.unshift File.expand_path(File.dirname(__FILE__), %w{ lib }) # For use/testing when no gem is installed

# A sample Guardfile
# More info at https://github.com/guard/guard#readme
require 'stitch-rb'
require 'uglifier'
require 'coffee-script'
require 'digest/md5'
require 'octopress'

configuration = Octopress::Configuration.read_configuration

stylesheets_dir    = "#{config[:assets]}/#{configuration[:stylesheets]}"
javascripts_dir    = "#{config[:assets]}/#{configuration[:javascripts]}"
assets_destination = "#{configuration[:source]}/assets"

guard :compass do
  watch %r{^#{stylesheets_dir}/(.*)\.s[ac]ss$}
end

guard :shell do
  # If a template file changes, trigger a Jekyll build
  watch /^#{configuration[:source]}\/.+\.(md|markdown|textile|html|haml|slim|xml)/ do
    Thread.new { system 'jekyll' }
  end
  watch /^#{javascripts_dir}\/.+\.(js|coffee|mustache|eco|tmpl)/ do |change|
    compile_javascript
  end
  # If a non template file changes, copy it to destination 
  watch /^#{configuration[:source]}\/.+\.[^(md|markdown|textile|html|haml|slim|xml)]/ do |m|
    file = File.basename(m.first)
    path = m.first.sub /^#{configuration[:source]}/, "#{configuration[:destination]}"
    FileUtils.mkdir_p path.sub /#{file}/,''
    FileUtils.cp m.first, path
    "\nCopied #{m.first} to #{path}"
  end
end

def compile_javascript
  lib = configuration[:require_js][:dependencies].collect {|item| Dir.glob("#{javascripts_dir}/#{item}") }.flatten.uniq
  all = configuration[:require_js][:modules].collect {|item| Dir.glob("#{javascripts_dir}/#{item}") }.flatten.uniq
  name = Digest::MD5.hexdigest(all.concat(lib).uniq.map! do |path|
    "#{File.mtime(path).to_i}"
  end.join)
  all = all.delete_if { |f| lib.include? f }

  path = "#{assets_destination}/#{configuration[:javascripts]}"
  file = "#{path}/#{name}.js"
  if File.exist? file
    "File #{file} unchanged."
  else

    js = Stitch::Package.new(:root => javascripts_dir, :dependencies => lib, :files => all).compile
    js = Uglifier.new.compile js unless Octopress.env == 'development'
    FileUtils.rm_r path, :secure=>true if File.directory? path
    FileUtils.mkdir_p path
    File.open(file, 'w') { |f| f.write js }
    "Compiled to #{file}."
  end
end
