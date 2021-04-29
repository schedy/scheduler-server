require 'cgi'

class String

	def html_class_name
		gsub(/[^A-Za-z0-9]/, '_').gsub(/^[^A-Za-z]/, '_')
	end

end



class HtmlAstNode < Annotator::AstNode

	attr_reader :tags
	dsl_value_writer :element, :title, :id, :html

	def initialize(*args)
		@classes = []
		@attributes = []
		super
	end


	def klass(k)
		@classes << k
	end


	def attribute(attribute, value)
		@attributes << [attribute, value]
	end


	def emit(content)
		content = @html if @html
		if @element
			'<%s%s%s%s%s>%s</%s>'%[
				@element,
				@id ? ' id="'+@id+'"' : '',
				@classes.size > 0 ? ' class="'+@classes.join(' ')+'"' : '',
				@title ? ' title="'+@title+'"' : '',
				@attributes.map { |attribute, value| attribute+'="'+value+'"' }.join(' '),
				content,
				@element]
		elsif @element == false
		else
			content
		end
	end


	def escape(text)
		CGI::escapeHTML(text)
	end


end
