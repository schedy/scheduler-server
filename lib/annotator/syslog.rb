element 'table'
id 'data-table'
klass 'table-condensed'
klass 'table'

each(/^.*[\n\Z]/) {

	element 'tr'
	klass 'line'

	each(/(?<date>[A-Z][a-z]{2} +\d+ \d\d:\d\d:\d\d) (?<host>\S+) (?<user>[^\.]+)\.(?<level>\S+) (?<process>\S+)\: ((?<file>[^:]+)\: )?(?<message>.*)/) {

		date {
			element 'td'
			klass 'column-timestamp'
		}

		level {
			element 'td'
			klass 'column-loglevel'
			parent.parent.tag 'loglevel', ->{ text }
		}

		process {
			element 'td'
			klass 'column-process'
			parent.parent.tag 'process', ->{ text }
		}

		file {
			element 'td'
			klass 'column-file'
		}

		message {

			each(/.*(?<source_label>LOG SOURCE:)(?<source>[^\|]+)(?<separator>\| )(?<message_label>LOG MESSAGE: )(?<message>.+)$/) {

				source_label { element false }

				source {
					element 'td'
					klass 'column-source'
					parent.parent.parent.parent.tag 'source', ->{ text }
				}

				separator {
					element 'td'
					klass 'column-separator'
					html '➜ '
				}

				message_label { element false }

				message {
					element 'td'
					klass 'column-message'
					each(/\b[A-Fa-f0-9]{2}+\b/) {
						element 'mark'
						title ->{
							'HEX->DEC: ' + text.to_i(16).to_s +
							"\nHEX->BIN: " + (num=text.to_i(16)).to_s(2).rjust((num.size/8.0).ceil*8,'0').scan(/.{4}/).join(' ')  +
							(text =~ /^[0-9]+$/ ? "\nDEC->HEX: "+text.to_i(10).to_s(16) : '')+
							(text =~ /^[0-9]+$/ ? "\nDEC->BIN: "+(num=text.to_i(10)).to_s(2).rjust((num.size/8.0).ceil*8,'0').scan(/.{4}/).join(' ') : '') +
							(text =~ /^[0-1]+$/ ? "\nBIN->HEX: "+text.to_i(2).to_s(16) : '')+
							(text =~ /^[0-1]+$/ ? "\nBIN->DEC: "+text.to_i(2).to_s(10) : '')+
							''
						}
					}
				}

			}

			each(/(?<source>)(?<message>.+)$/) {
				element  'td'
				klass 'column-message'
				#attribute "colspan", "3"
				parent.parent.parent.tag 'source', 'missing'
				source {
					element 'td'
					klass 'column-source'
					html ''
				}
				message {
					element 'td'
					klass 'column-message'
				}
			}

		}

		each(/.+/) {
			element false
		}
	}

}
