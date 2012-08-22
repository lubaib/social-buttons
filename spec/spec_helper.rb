# coding: utf-8
require 'rubygems'
require 'rails'
require 'json'
require 'active_support'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'action_view/template'

require 'active_support/core_ext/hash'

require 'rspec'
require 'social_buttons'

SPEC_DIR = File.dirname(__FILE__)

class DummyController
  def method_missing(meth, *args, &block)
    meth
  end
end

module ControllerTestHelpers

  def self.included(base)
    base.class_eval do
      
      include ActionView::Helpers,
              ActionView::Helpers::CaptureHelper,
              ActionView::Helpers::JavaScriptHelper,
              ActionView::Helpers::AssetTagHelper,
              ActionDispatch::Routing,
              ActionView::Helpers::UrlHelper

      # allow tabs.create to run by stubbing an output_buffer
      attr_accessor :output_buffer
      @output_buffer = ""
  
      def link_to adr, *args
        options = args.extract_options!          
        content_tag :a, adr, {:href => adr}.merge(options)
      end

      def controller
        @controller ||= DummyController.new
      end

      def url_for adr, *args
        "dummy/path/#{adr}/#{args}".html_safe
      end

      def _routes_context
        controller
      end

      # stub content_for for testing
      def content_for(name, content = nil, &block)
        # this doesn't exist, and causes errors
        @_content_for = {} unless defined? @_content_for
        # we've got to initialize this, so we can concat to it
        @_content_for[name] = '' if @_content_for[name].nil?
        # now the rest is the same as in rails
        content = capture(&block) if block_given?
        @_content_for[name] << content if content
        @_content_for[name] unless content
      end    
    end
  end
end