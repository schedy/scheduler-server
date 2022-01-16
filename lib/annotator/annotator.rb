#!/usr/bin/ruby

class String
	def ellipsis
		size < 12 ? self : self[0..5] + '...' + self[-6..-1]
		#self
	end
end

module Annotator

	class Firewall
		def method_missing(*_)
			raise StandardError, "Oh come on, you can't do this here! Use ->{} instead"
		end
	end

	class ParentProxy
		def initialize(parser_node_ast_parameters, depth)
			@parser_node_ast_parameters = parser_node_ast_parameters
			@depth = depth
		end

		def parent
			ParentProxy.new(@parser_node_ast_parameters, @depth+1)
		end

		def method_missing(name, *args)
			@parser_node_ast_parameters << [@depth, name, *args]
		end
	end

	class ParserNode
		def initialize(ast_node_class, name, regexp = nil, &block)
			#puts "INIT: " + name.inspect + " " + regexp.inspect + " " + block_given?.inspect
			@ast_node_class = ast_node_class
			@name = name
			@regexp = regexp
			@names = {}
			@each = []
			@ast_parameters = []

			if block_given?
				self.instance_eval(&block)
			end
		end

		def each(regexp, &block)
			@each << ParserNode.new(@ast_node_class, nil, regexp, &block)
		end

		def method_missing(name, *args, &block)
			#puts 'MM: ' + name.to_s
			if @regexp and @regexp.names.include?(name.to_s)
				if block_given?
					raise 'Duplicated name: '+name if @names[name]
					@names[name.to_s] = ParserNode.new(@ast_node_class, name, *args, &block)
				else
					ParserNode.new(@ast_node_class, name, regexp)
				end
			else
				@ast_parameters << [0, name, *args]
			end
			Firewall.new()
		end

		def parent
			ParentProxy.new(@ast_parameters, 1)
		end

		def root
			ParentProxy.new(@ast_parameters, -1)
		end

		def parse(ast_node, input)
			#puts "Parsing: %s"%[input.ellipsis]
			#puts "Parsing: %s in %s"%[input.ellipsis, self.inspect]
			ret = []
			to_check = nil
			if @regexp
				original = input
				while input.size > 0 and match = @regexp.match(input)
					ret << match.pre_match if match.pre_match.size > 0
					ret << instantiate(ast_node, input, match)
					input = match.post_match
				end
				ret << input if input.size > 0
			else
				ret << instantiate(ast_node, input, nil)
			end
			ret
		end

		def instantiate(parent_ast_node, text, match)
			#puts "Instantiating AST Node for %s"%[text.ellipsis.inspect]
			#raise if text.size == 0

			ast_node = @ast_node_class.new(parent_ast_node, (match or text).to_s, @ast_parameters)
			chain = []
			if match
				cursor = match.begin(0)
				match.names.map { |name| [*match.offset(name), name] }.each { |start, finish, name|
					next if (not @names[name])
					if start
						chain << text[cursor...start] if cursor < start
						chain << @names[name].parse(ast_node, text[start...finish])
						cursor = finish
					else
						chain << @names[name].parse(ast_node, '')
					end
				}
				chain << text[cursor...match.end(0)] if cursor < match.end(0)
			else
				chain << text
			end

			nil while chain.find.with_index { |element, i|
				next if not element.kind_of? String
				found = @each.find { |free|
					parsed = free.parse(ast_node, element)
					next if parsed == [element]
					chain[i] = parsed
					chain.flatten!
				}
			}

			ast_node.chain = chain.flatten
			ast_node
		end
	end

	class AstNode
		attr_writer :chain
		attr_reader :text, :parent

		def initialize(parent, text, parameters)
			@parent = parent
			@text = text
			@chain = []
			parameters.each { |depth, name, *args|
				object = self
				object = root if depth < 0
				depth.times { object = object.parent } if depth > 0
				object.__send__(name, *args.map { |value| value.kind_of?(Proc) ? (instance_exec(&value)) : value })
			}
		end

		def inspect
			'<AstNode element=%s text=%s chain=%s>'%[@element, @text.ellipsis.inspect, @chain.map { |node| node.kind_of?(String) ? node.ellipsis : node }.inspect]
		end

		def pp(level = 0)
			(indent="\t"*level)+"<AstNode element=%s text=%s\n"%[@element, @text.ellipsis.inspect]+
			@chain.map { |node| node.kind_of?(String) ? (indent+"\t"+node.ellipsis.inspect) : node.pp(level+1) }.join("\n")
		end

		def root
			return self if not @parent
			@parent.root
		end

		def compile
			content = @chain.map { |node|
				if node.kind_of?(String)
					escape(node)
				else
					node.compile
				end
			}.flatten.join('')

			emit(content)
		end

		def escape(text)
			text
		end

		def emit(_content)
			raise 'Pls define your own emit'
		end

		def self.dsl_value_writer(*names)
			names.each { |name|
				self.__send__(:define_method, name, Proc.new { |value|
					self.instance_variable_set('@'+name.to_s, value)
				})
			}
		end
	end

	class Parser
		def initialize(ast_node_class, program, program_file = 'AnnotatorProgram')
			@root_parser_node = ParserNode.new(ast_node_class, :root, nil) {
				binding.eval(program.force_encoding('UTF-8'), program_file)
			}
		end

		def parse(text)
			@root_parser_node.parse(nil, text)[0]
		end
	end

end
