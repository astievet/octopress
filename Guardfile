# A sample Guardfile
# More info at https://github.com/guard/guard#readme
require 'stitch-rb'
require 'uglifier'
require 'coffee-script'

env                = "prod"
assets_source      = "assets"
jekyll_source      = "source"
jekyll_destination = "public"
stylesheets_dir    = "#{assets_source}/stylesheets"
javascripts_dir    = "#{assets_source}/javascripts"
assets_destination = "#{jekyll_source}/assets"

guard :compass do
  watch %r{^#{stylesheets_dir}/(.*)\.s[ac]ss$}
end


guard :shell do
  watch /^#{jekyll_source}\/.+\.(md|markdown|textile|html|haml|slim|xml)/ do
    Thread.new { system 'jekyll' }
  end
  watch /^#{javascripts_dir}\/.+\.(js|coffee)/ do |change|
    file = change.first
    if env == 'development'
      copy_asset(file)
    else
      compile_javascript
    end
  end
  watch /^#{jekyll_source}\/.+\.[^(md|markdown|textile|html|haml|slim|xml)]/ do |m|
    file = File.basename(m.first)
    path = m.first.sub /^#{jekyll_source}/, "#{jekyll_destination}"
    FileUtils.mkdir_p path.sub /#{file}/,''
    FileUtils.cp m.first, path
    "\nCopied #{m.first} to #{path}"
  end
end

def copy_asset(path)
  output = "#{assets_destination}/javascripts/#{File.basename(path).sub /\.coffee/, ''}"
  output += '.js' unless File.extname(output) == 'js'
  if File.extname(path) == 'coffee'
    File.open(output, 'w') do |f|
      f.write CoffeeScript.compile File.read(path)
    end
  else
    FileUtils.cp path, "#{assets_destination}/javascripts"
  end
  "Copied #{path} to #{output}"
end

def compile_javascript
  lib = Dir.glob('lib/**/*.coffee').concat Dir.glob('lib/**/*.js')
  all = Dir.glob("#{javascripts_dir}/**/*.js").concat Dir.glob("#{javascripts_dir}/**/*.coffee")
  name = Digest::MD5.hexdigest(all.map! do |path|
    "#{File.mtime(path).to_i}"
  end.join)
  all = all.delete_if { |f| lib.include? f }
  path = "#{assets_destination}/javascripts"
  file = "#{path}/#{name}.js"
  if File.exist? file
    ""
  else
    js = Uglifier.new.compile Stitch::Package.new(:paths => all, :dependencies => lib).compile
    FileUtils.rm_r path, :secure=>true if File.directory? path
    FileUtils.mkdir_p path
    File.open(file, 'w') { |f| f.write js }
    "Compiled to #{file}"
  end
end
