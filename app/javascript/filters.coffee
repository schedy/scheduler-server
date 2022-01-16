window.Filters =
        view: (vnode)->
                m '.container-fluid',
                        m '.row.container-filter-header',
                                m '.filter-header.filter-header-grid', 'filters'
                                m 'button.btn.extra-filter.btn.btn-outline-primary.btn-xs',{'type':'button','data-bs-toggle':"collapse",'data-bs-target':'#extrafilters'}, 'More'
                                m '.form-floating.filter-search-input-container-grid',
                                        m 'input.form-control.filter-search-input.filter-input',{'id':'filterSearch','data-router-field':'search','type':'text','placeholder':'Filter by ID or tags', value: router.state.executions_filter["search"]}
                                        m 'label',{"for":'filterSearch'},'Filter by ID or tags'
                        m 'ul#filters.list-unstyled',
                                if execution_filters? and execution_filters.initialized
                                        ## TODO: Rework this lambda, replace _map with entries.
                                        grouped_tags = _.groupBy execution_filters.object.tags, (obj) -> obj.substring(0,obj.indexOf(':'))
                                        arrayed_tags = _.sortBy(_.map(grouped_tags, (v, k) ->
                                                obj = {}
                                                obj[k] = v
                                                obj
                                                ), (z) ->
                                                        Object.values(z)[0].length
                                                ).reverse()
                                        for k of arrayed_tags
                                                key = Object.keys(arrayed_tags[k])[0] #TODO: remove once project moves off coffeescript
                                                value = Object.values(arrayed_tags[k])[0]
                                                m 'li',
                                                        m 'hr',style: {margin: '3px'}
                                                        m 'span.filter-parent',key,
                                                                m 'a[href="?'+(_.contains(router.state.hidden_tags,key) and '-' or '')+'hidden_tags~='+key+'"]',{'data-parent-tag': key}, (_.contains(router.state.hidden_tags,key) and '▼' or '▲')
                                                        if ( undefined == router.state.hidden_tags) or (!_.contains(router.state.hidden_tags,key))
                                                                for tag in value
                                                                        selected = _.contains(router.state.executions_filter.tags,tag)
                                                                        m 'li.filter-child',
                                                                                m 'a', class: (selected and "filter-selected" or ""), href: '?'+(selected and '-' or '')+'executions_filter.tags~='+tag, 'data-parent-tag': tag.split(':')[0], 'data-child-tag': tag.split(':')[1], (selected and '☒' or '☐') + ' ' + tag.substring(tag.indexOf(':')+1)

                        m Spinner if (not execution_filters?) or (not execution_filters.valid)

