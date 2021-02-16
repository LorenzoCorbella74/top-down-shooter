local messageQueue = {}

messageQueue.new = function(handlers)

    local self = {handlers = handlers}
    local messages = {}

    function self.createMsg(handler, to, from, type, data)
        return {
            handler = handler,  -- handler (can be single (powerups, bullets), but also "all", comma separated, etc TODO )
            to = to,            -- a reference to the entity that will receive this message
            from = from,        -- a reference to the entity that sent this message
            type = type,        -- the type of this message
            data = data         -- the content/data of this message
        }
    end

    function self.addMsg(msg) table.insert(messages, msg) end

    function self.dispatch()
        for _i = #messages, 1, -1 do
            -- Fetch the entity that should receive this message 
            local message = messages[_i]
            local handler = message.handler
            -- If that entity exists, deliver the message.
            if handler and self.handlers[handler].onMessage then
                self.handlers[handler].onMessage(message)
            end
            -- Delete the message from the queue
            table.remove(message)
        end
    end

    return self

end

return messageQueue

