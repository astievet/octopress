$:.unshift File.expand_path(File.dirname(__FILE__)) # For use/testing when no gem is installed

module Octopress
  module Assets

    def self.config
      config = Octopress::Configuration.read_configuration
    end

    # Read js dependencies from configuration
    def self.js_dependencies
      p config[:require_js]
      config[:require_js][:dependencies].collect {|item| Dir.glob("#{javascripts_dir}/#{item}") }.flatten.uniq
    end

    # Read js modules from configuration
    def self.js_modules
      p config[:require_js]
      config[:require_js][:modules].collect {|item| Dir.glob("#{javascripts_dir}/#{item}") }.flatten.uniq
    end

    def self.js_fingerprint
      Digest::MD5.hexdigest(js_modules.concat(js_dependencies).uniq.map! do |path|
        "#{File.mtime(path).to_i}"
      end.join)
    end

    def self.compile_js
      fingerprint = js_fingerprint
      js_destination_dir = "#{config[:source]}/javascripts/build"
      file = (Octopress.env == 'production' ?  "#{js_destination_dir}/all-#{fingerprint}.js" : "#{js_destination_dir}/all.js" )
     
      if File.exists?(file) and File.open(file) {|f| f.readline} =~ /#{fingerprint}/
        "File #{file} unchanged."
      else
        dependencies = js_dependencies
        modules = js_modules.delete_if { |f| dependencies.include? f }

        js = Stitch::Package.new(:root => javascripts_dir, :dependencies => dependencies, :files => modules).compile
        js = "/* Octopress fingerprint: #{fingerprint} */\n" + js
        js = Uglifier.new.compile js if Octopress.env == 'production'

        (Dir["#{assets_destination}/*"]).each { |f| rm_rf(f) }
        FileUtils.mkdir_p assets_destination
        File.open(file) { |f| f.write js }

        "Javascripts compiled to #{file}."
      end
    end
  end
end
