#!/usr/bin/ruby

require_relative 'annotator.rb'
require_relative 'html-ast-node.rb'

class SyslogHtmlAstNode < HtmlAstNode
	attr_reader :tags

	def initialize(*args)
		@tags = {}
		super
	end

	def tag(tag, value = true)
		(@tags[tag] ||= []) << value
		(root.tags[tag] ||= []) << value
		@classes << SyslogHtmlAstNode.tag_value_class(tag, value)
	end

	def self.tag_value_class(tag, value)
		'tag-'+tag.html_class_name+'-'+value.html_class_name
	end
end

require 'json'
require 'erb'
require 'coffee-script'
require 'sass'
require 'sass/exec'

def erb(file_name, binding)
        ERB.new(open(file_name).read).result(binding)
end

def sass(file_name, binding)
        Sass.compile(erb(file_name, binding), syntax: :sass)
end

def coffee(file_name, binding)
	CoffeeScript.compile(erb(file_name, binding))
end

def text(file_name)
        open(file_name).read
end

parser = open(ARGV[0]) { |file| Annotator::Parser.new(SyslogHtmlAstNode, file.read, ARGV[0]) }
ast = parser.parse($stdin.read)
data = ast.compile
attributes = ast.tags.to_a.map { |attribute, values|
	{
		name: attribute,
		values: values.sort.uniq.map { |value|
			{
				name: value,
				class: SyslogHtmlAstNode.tag_value_class(attribute, value)
			}
		}
	}
}.sort_by { |attribute| attribute[:name] }

attributes << {
	name: 'columns',
	values: [
		{ name: 'timestamp', class: 'column-timestamp' },
		{ name: 'loglevel', class: 'column-loglevel' },
		{ name: 'process', class: 'column-process' },
		{ name: 'file', class: 'column-file' },
		{ name: 'source', class: 'column-source' },
		{ name: 'message', class: 'column-message' }
	]
}

script = coffee('lib/annotator/syslog.coffee.erb', binding)
style = sass('lib/annotator/syslog.css.sass.erb', binding)
html = erb('lib/annotator/syslog.html.erb', binding)
puts html

#$stderr.puts ast.pp
#$stderr.puts ast.tags
