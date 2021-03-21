class @SeapigRouter


        constructor: (seapig_client, options={})->
                @seapig_client = seapig_client
                @session_id = undefined
                @mountpoint = (options.mountpoint or "/")
                @default_state = (options.default or {})
                @debug = options.debug
                @expose = (options.expose or [])
                @cast = (options.cast or (state)-> state)
                @onsessionopen = options.onsessionopen

                @token = (String.fromCharCode(48 + code + (if code > 9 then 7 else 0) + (if code > 35 then 6 else 0)) for code in (Math.floor(Math.random()*62) for i in [0..11])).join("")
                console.log('ROUTER: Generated token: ', @token) if @debug

                @state = undefined
                @state_id = 1
                @state_raw = { session_id: undefined, state_id: 0, state_parent: undefined, state_committed: true }
                @state_valid = false

                commit_scheduled_at = null
                commit_timer = null
                remote_state = null

                priv = {}
                @private = priv if options.expose_privates

                session_data = @seapig_client.master('SeapigRouter::Session::'+@token+'::Data', object: { token: @token, session: @session_id, states: {}})
                session_data.bump()

                session_data_saved = @seapig_client.slave('SeapigRouter::Session::'+@token+'::Saved')
                session_data_saved.onchange =>
                        return if not session_data_saved.valid
                        for state_id in _.keys(session_data.object.states)
                                delete session_data.object.states[state_id] if parseInt(state_id) < session_data_saved.object.max_state_id
                        if not @session_id?
                                @session_id = session_data_saved.object.session_id
                                @state.session_id = @state_raw.session_id = @session_id if @state? and not @state_raw.session_id?
                                console.log('ROUTER: Session opened', @session_id) if @debug
                                @onsessionopen(@session_id) if @onsessionopen?
                        console.log('ROUTER: Session saved up till:', session_data_saved.object.max_state_id) if @debug
                        location_update(false) if @state_valid


                document.addEventListener("click", (event) =>
                        return true if not (event.button == 0)
                        href = (event.target.getAttribute("href") or "")
                        console.log('ROUTER: A-element clicked, changing location to:', href) if @debug
                        return true if not (href[0] == '?')
                        @navigate(href)
                        event.preventDefault()
                        false)


                window.onpopstate = (event) =>
                        previous_state = @state_raw
                        @state_raw = JSON.parse(JSON.stringify(event.state))
                        @state_raw.session_id = @session_id if not @state_raw.session_id?
                        @state = @cast(JSON.parse(JSON.stringify(@state_raw)))
                        console.log('ROUTER: History navigation triggered. Going to:', event.state) if @debug
                        location_update(false)
                        @onchange(@state_raw, previous_state) if @onchange?


                state_permanent = (state)=>
                        _.omit(state, (value, key)-> key.indexOf("_") == 0 or key == "session_id" or key == "state_id" or key == "state_parent" or key == "state_committed")


                state_diff_generate = priv.state_diff_generate = (state1, state2)=>

                        element_diff = (diff, address, object1, object2)->
                                same_type = ((typeof object1 == typeof object2) and (Array.isArray(object1) == Array.isArray(object2)))
                                if (not object2?) or (object1? and not same_type)
                                        diff.push ['-'+address, '-']
                                        object1 = undefined
                                if Array.isArray(object2)
                                        array_diff(diff, address+"~", object1 or [], object2)
                                else if typeof object2 == 'object'
                                        object_diff(diff, address+".", object1 or {}, object2)
                                else if object2?
                                        diff.push [address, object2] if object1 != object2

                        object_diff = (diff, address, object1, object2)->
                                for key in _.uniq(_.union(_.keys(object1), _.keys(object2)))
                                        element_diff(diff, address+key, object1[key], object2[key])
                                diff

                        array_diff = (diff, address, array1, array2)->
                                j = 0
                                for element1, i in array1
                                        if _.isEqual(element1, array2[j])
                                                j++
                                        else
                                                k = j
                                                k++ while (not _.isEqual(element1,array2[k])) and (k < array2.length)
                                                if k == array2.length
                                                        if typeof element1 == 'object'
                                                                diff.push ["-"+address+j+"~", "-"]
                                                        else
                                                                diff.push ["-"+address+"~", element1]
                                                else
                                                        while j < k
                                                                element_diff(diff, address+j+"~", undefined, array2[j++])
                                                        j++

                                while j < array2.length
                                        element_diff(diff, address+"~", undefined, array2[j++])

                        object_diff([], "",  state1, state2)


                state_diff_apply =  priv.state_diff_apply = (state, diff)=>
                        for entry in diff
                                address = entry[0]
                                value = entry[1]
                                add = (address[0] != '-')
                                address = address[1..-1] if address[0] == '-'
                                obj = state
                                spl = address.split('.')
                                for subobj,i in spl
                                        if i < (spl.length-1)
                                                if subobj[subobj.length-1] == '~'
                                                        if subobj.split("~")[1].length > 0
                                                                obj[parseInt(subobj.split("~")[1])] = {} if not obj[parseInt(subobj.split("~")[1])]
                                                                obj = obj[parseInt(subobj.split("~")[1])]
                                                        else
                                                                obj[subobj.split("~")[0]] = [new_obj = {}]
                                                                obj = new_obj
                                                else
                                                        obj[subobj] = {} if not obj[subobj]?
                                                        obj = obj[subobj]
                                address = spl[spl.length-1]
                                hash = (address[address.length-1] != '~')
                                index = undefined
                                index = parseInt(address.split('~')[1]) if (not hash) and address.split("~")[1].length > 0
                                address = address.split("~")[0]
                                if add
                                        if hash
                                                obj[address] = value
                                        else
                                                if index?
                                                        (obj[address] ||= []).splice(index,0,value)
                                                else
                                                        (obj[address] ||= []).push(value)
                                else
                                        if hash
                                                delete obj[address]
                                        else
                                                if index?
                                                        obj[address].splice(index,1)
                                                else
                                                        obj[address].splice(_.indexOf(obj[address], value),1)
                        state


                url_to_state_description = (pathname, search)=>

                        # URL FORMAT:
                        # /VERSION/SESSION_ID/STATE_ID/[EXPOSED_DIFF/][-/BUFFER_DIFF][?CHANGE_DIFF]
                        # VERSION - format code
                        # SESSION_ID
                        # STATE_ID - id of latest state saved on server
                        # EXPOSED DIFF - "pretty" part of the url, exposing selected state components for end user manipulation.
                        # BUFFER_DIFF - temporary section, holding the difference between STATE_ID state and current state. vanishes after current state gets saved on server.
                        # CHANGE_DIFF - temporary section, holding state change intended by <A> link (e.g. href="?view=users&user=10"). vanishes immediately and gets transeferred to BUFFER_DIFF.

                        state_description = { session_id: null, state_id: null, buffer: [], exposed: [], change: [] }

                        spl = pathname.split(@mountpoint)
                        spl.shift()
                        spl = (decodeURIComponent(part) for part in spl.join(@mountpoint).split('/'))

                        version = spl.shift()
                        if version == 'a'
                                state_description.session_id = spl.shift()
                                state_description.session_id = undefined if state_description.session_id == '_'
                                state_description.state_id = spl.shift()

                        if state_description.state_id?
                                while spl.length > 0
                                        key = spl.shift()
                                        break if key == '-'
                                        component = _.find @expose, (component)-> component[1]
                                        next if not component
                                        state_description.exposed.push([component[0],spl.shift()])

                                while spl.length > 0
                                        state_description.buffer.push([spl.shift(),spl.shift()])
                        else
                                state_description.session_id = @session_id
                                state_description.state_id = 0
                                state_description.buffer = state_diff_generate(state_permanent(@state_raw), state_permanent(@default_state))

                        if search.length > 1
                                for pair in search.split('?')[1].split('&')
                                        decoded_pair = (decodeURIComponent(part) for part in pair.split('=',2))
                                        state_description.change.push(decoded_pair)

                        console.log('ROUTER: Parsed location', state_description) if @debug
                        state_description


                state_description_to_url = (state_description)=>
                        console.log('ROUTER: Calculating url for state description:', state_description) if @debug
                        url = @mountpoint+'a/'+(state_description.session_id or '_')+'/'+state_description.state_id
                        url += "/"+(encodeURIComponent(component) for component in  _.flatten(state_description.exposed)).join("/") if state_description.exposed.length > 0
                        url += "/-/"+(encodeURIComponent(component) for component in  _.flatten(state_description.buffer)).join("/") if state_description.buffer.length > 0
                        console.log('ROUTER: Calculated url:', url) if @debug
                        url


                state_set_from_state_description = (state_description, defer, replace)=>

                        state_commit = (replace) =>
                                console.log("ROUTER: Committing state:",@state_raw) if @debug
                                @state_raw.state_committed = true
                                session_data.object.states[@state_raw.state_id] = state_permanent(@state_raw)
                                session_data.bump()
                                clearTimeout(commit_timer) if commit_timer
                                commit_scheduled_at = null
                                commit_timer = null
                                location_update(replace)

                        commit_needed_at = Date.now() + defer

                        if not @state_raw.state_committed
                                last_committed_state = @state_raw.state_parent
                        else
                                last_committed_state = @state_raw

                        console.log("ROUTER: Changing state. Commit deferred by", defer, "to be done at", commit_needed_at, " State before mutation:",last_committed_state) if @debug

                        previous_state = @state_raw
                        new_state = JSON.parse(JSON.stringify(state_permanent(@state_raw)))
                        new_state = state_diff_apply(new_state, state_description.buffer)
                        new_state = state_diff_apply(new_state, state_description.exposed)
                        new_state = state_diff_apply(new_state, state_description.change)
                        _.extend(new_state, _.pick(previous_state, (value,key)-> key.indexOf("_") == 0))

                        if state_diff_generate(state_permanent(last_committed_state), state_permanent(new_state)).length > 0
                                new_state.state_committed = false
                                if previous_state.state_committed
                                        new_state.session_id = @session_id
                                        new_state.state_id = @state_id++
                                        new_state.state_parent = previous_state
                                else
                                        new_state.session_id = previous_state.session_id
                                        new_state.state_id = previous_state.state_id
                                        new_state.state_parent = previous_state.state_parent
                        else
                                new_state.session_id = last_committed_state.session_id
                                new_state.state_id = last_committed_state.state_id
                                new_state.state_parent = last_committed_state.state_parent
                                new_state.state_committed = last_committed_state.state_committed

                        @filter(new_state, previous_state) if @filter?
                        @state_raw = new_state
                        @state = @cast(JSON.parse(JSON.stringify(@state_raw)))
                        @state_valid = true

                        if @state_raw.state_committed
                                clearTimeout(commit_timer) if commit_timer
                                commit_scheduled_at = null
                                commit_timer = null
                        else
                                if commit_needed_at <= Date.now()
                                        state_commit(replace)
                                else
                                        location_update(false)
                                        if (not commit_scheduled_at) or (commit_needed_at < commit_scheduled_at)
                                                console.log("ROUTER: Deferring commit by:", defer, "till", commit_needed_at) if @debug
                                                @state_raw.state_committed = false
                                                clearTimeout(commit_timer) if commit_timer
                                                commit_scheduled_at = commit_needed_at
                                                commit_timer = setTimeout((()=> state_commit(replace)), commit_scheduled_at - Date.now())

                        @onchange(@state_raw,previous_state) if @onchange?


                state_get_as_state_description = (state)=>
                        last_committed_state = state
                        while last_committed_state.state_parent and ((not last_committed_state.session_id) or last_committed_state.session_id == @session_id) and ((session_data_saved.object.max_state_id or 0 ) < last_committed_state.state_id)
                                last_committed_state = last_committed_state.state_parent
                        console.log('ROUTER: Last shareable state:', last_committed_state) if @debug
                        buffer = state_diff_generate(state_permanent(last_committed_state), state_permanent(state))
                        exposed = ([component[1], pair[1]] for pair in state_diff_generate({}, state) when component = _.find @expose, (component)-> component[0] == pair[0])
                        buffer = (pair for pair in buffer when not _.find @expose, (component)-> component[0] == pair[0])
                        { session_id: last_committed_state.session_id, state_id: last_committed_state.state_id, exposed: exposed, buffer: buffer, change: [] }


                location_update = (new_history_entry)=>
                        url = state_description_to_url(state_get_as_state_description(@state_raw))
                        console.log("ROUTER: Updating location:    state:", @state_raw, '    url:', url) if @debug
                        if new_history_entry
                                window.history.pushState(@state_raw,null,url)
                        else
                                window.history.replaceState(@state_raw,null,url)


                @navigate = (search, options = {})->
                        pathname = window.location.pathname

                        console.log('ROUTER: Navigating to:    pathname:', pathname, '    search:', search) if @debug
                        state_description = url_to_state_description(pathname, search)
                        console.log('ROUTER: New state description:', state_description) if @debug

                        if remote_state?
                                remote_state.unlink()
                                remote_state = null

                        if state_description.session_id == @session_id or state_description.state_id == "0"
                                state_set_from_state_description(state_description, (options.defer or 0), !options.replace)
                        else
                                @state_valid = false
                                remote_state = @seapig_client.slave('SeapigRouter::Session::'+state_description.session_id+'::State::'+state_description.state_id)
                                remote_state.onchange ()=>
                                        return if not remote_state.valid
                                        console.log("ROUTER: Received remote state", remote_state.object) if @debug
                                        @state_raw = JSON.parse(JSON.stringify(remote_state.object))
                                        @state_raw.state_committed = true
                                        @state_raw.session_id = state_description.session_id
                                        @state_raw.state_id = state_description.state_id
                                        @state_raw.state_parent = undefined
                                        state_set_from_state_description(state_description, (options.defer or 0), !options.replace)
                                        remote_state.unlink()
                                        remote_state = null


                @volatile = (data...)->
                        if data.length == 1 and typeof data[0] == 'object'
                                for key, value of data[0]
                                        @state["_"+key] = value
                                _.extend(@state_raw, _.pick(@state, (value,key)-> key.indexOf("_") == 0))
                                window.history.replaceState(@state_raw,null,window.location)
                        else
                                _.object(([key, @state["_"+key]] for key in data))
