window.Filters =
        view: (vnode)->
                m '.container-fluid', style: { position: 'relative', "min-height": "200px", overflow: "hidden" },
                        m '.filter-header', 'filters'
                        m '.input-group',
                                m 'input.form-control.filter-search-input',{'type':'text','placeholder':'Filter by ID', value: router.state.executions_filter["search"]}
                        m 'ul#filters.list-unstyled',
                                if execution_filters? and execution_filters.initialized
                                        grouped_tags = _.groupBy execution_filters.object.tags, (obj) -> obj.substring(0,obj.indexOf(':'))
                                        for key,value of grouped_tags
                                                m 'li',
                                                        m 'hr',style: {margin: '3px'}
                                                        m 'span.filter-parent',key,
                                                                m 'a[href="?'+(_.contains(router.state.hidden_tags,key) and '-' or '')+'hidden_tags~='+key+'"]',{'data-parent-tag': key}, (_.contains(router.state.hidden_tags,key) and '▼' or '▲')
                                                        if ( undefined == router.state.hidden_tags) or (!_.contains(router.state.hidden_tags,key))
                                                                for tag in value
                                                                        selected = _.contains(router.state.executions_filter.tags,tag)
                                                                        m 'li.filter-child',
                                                                                m 'a', class: (selected and "filter-selected" or ""), href: '?'+(selected and '-' or '')+'executions_filter.tags~='+tag, 'data-parent-tag': tag.split(':')[0], 'data-child-tag': tag.split(':')[1], (selected and '☑' or '☐') + ' ' + tag.substring(tag.indexOf(':')+1)

                        m Spinner if (not execution_filters?) or (not execution_filters.valid)

