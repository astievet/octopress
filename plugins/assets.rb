$:.unshift File.expand_path("lib", File.dirname(__FILE__)) # For use/testing when no gem is installed
require 'octopress'

class JavascriptAssets < Liquid::Tag
  def initialize(tag_name, options, tokens)
    super
  end

  def render(context)
    js = <<-EOF
<script src="/javascripts/build/all-#{Octopress::Assets.js_fingerprint}.js"></script>
<script>!window.require && document.write(unescape('%3Cscript src="/javascripts/build/all.js"%3E%3C/script%3E'))</script>
EOF
    js
  end
end

Liquid::Template.register_tag('javascript_assets_tag', JavascriptAssets)
