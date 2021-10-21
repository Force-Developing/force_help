local Threads = {}
local Offset = 1

AnimateUI = {}


function RandomID(length)
    local res = ""
    math.randomseed(GetGameTimer() + Offset)
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    Offset = Offset + 1
    return res
end

function MergeConfig(Copy, Settings)
    for k,v in pairs(Settings) do Copy[k] = v end
    return Copy
end

function Override(Settings, Key)
    local Element = Config[Key]
    if Settings ~= nil then
        if Settings[Key] ~= nil then
            Element = Settings[Key]
        end
    end
    
    return Element
end

-- MAIN RENDER THREADS
AnimateUI.Run = function(Message, Settings, Element, Func, Interval, Timeout, Exit, Callback)
    local Copy = {
        Font         = Config.Font,
        Size         = Config.Size,
        PositionX    = Config.PositionX,
        PositionY    = Config.PositionY,
        Opacity      = Config.Opacity
    }

    if Settings ~= nil then
        Copy = MergeConfig(Copy, Settings)
    end

    local Tick = true

    for Type, Value in pairs(Element) do
        if Value.Start ~= nil then
            Value.Start = { Key = Type, Value = Value.Start }
        else
            Value.Start = { Key = Type, Value = Copy[Type] }
        end

        if Value.End ~= nil then
            Value.End = { Key = Type, Value = Value.End }
        else
            Value.End = { Key = Type, Value = Copy[Type] }
        end

        -- Prevent message from showing at start
        Copy[Type] = Value.Start.Value
    end

    local Index = #Threads + 1
    local ID = RandomID(20)
    table.insert(Threads, Index, {
        Tick = true,
        ID = ID
    })

    local Thread = Threads[Index]
    
    Citizen.CreateThread(function()
        local StartTime = GetGameTimer()
        while Thread.Tick do
            local CurrentTime = GetGameTimer() - StartTime

            if CurrentTime < Interval then
                for Type, Value in pairs(Element) do
                    Copy[Type] = Easing[Func](CurrentTime, Value.Start.Value, Value.End.Value - Value.Start.Value, Interval)
                end
            else
                for Type, Value in pairs(Element) do
                    if Copy[Type] > Value.End.Value or Copy[Type] < Value.End.Value then
                        Copy[Type] = Value.End.Value
                    end
                end

                Citizen.Wait(Timeout)

                -- Exit animation
                if Exit ~= nil then
                    if type(Exit) == 'table' then
                        if Exit.Duration == nil then
                            Exit.Duration = Interval
                        end
                        AnimateUI[Exit.Effect](Message, Settings, Exit.Duration, 0, Callback)
                    elseif type(Exit) == 'string' then
                        AnimateUI[Exit](Message, Settings, Interval, 0, Callback)
                    end
                    Citizen.Wait(20)
                    Thread.Tick = false
                    Threads[Index] = nil
                    break
                else
                    Thread.Tick = false
                    Threads[Index] = nil
                    
                    if Callback ~= nil then
                        Callback(ID)
                    end
                end                     
            end
                     
            Citizen.Wait(0)
        end
    end)
                
    Citizen.CreateThread(function()
        while Thread.Tick do
            AnimateUI.RenderMessage(Message, Copy.PositionX, Copy.PositionY, Copy.Size, Copy.Font, math.floor(Copy.Opacity))
            Citizen.Wait(0)
        end
    end)

    return ID
end

AnimateUI.Kill = function(ID)
    for _, v in pairs(Threads) do
        if v.ID == ID then
            v.Tick = false
        end
    end
end

AnimateUI.RenderMessage = function(text, x, y, scale, font, a)
    if x == nil then  x = 0.5 end
    if y == nil then y = 0.5 end 
    if a == nil then a = 255 end   

    SetTextFont(font)
    SetTextProportional(true)
    SetTextCentre(true)
    SetTextScale(scale, scale)
    SetTextColour(Config.Color.R, Config.Color.G, Config.Color.B, a)
    SetTextDropShadow(0, 0, 0, 0, a)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, a)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end

-- discord effekten

AnimateUI.discordIn = function(Message, Settings, Interval, Timeout, Exit, Callback)
    local Count = 0
    local Length = string.len(Message)

    local Copy = {
        Font         = Config.Font,
        Size         = Config.Size,
        PositionX    = Config.PositionX,
        PositionY    = Config.PositionY,
        Opacity      = Config.Opacity
    }

    if Settings ~= nil then
        Copy = MergeConfig(Copy, Settings)
    end

    local Index = #Threads + 1
    local ID = RandomID(20)
    table.insert(Threads, Index, {
        Tick = true,
        ID = ID
    })

    local Thread = Threads[Index]

    Citizen.CreateThread(function()
        while Thread.Tick do
            if Count < Length then
                Count = Count + 1
                Str = string.sub(Message, 0, Count)

                if Count == Length then
                    Citizen.Wait(Timeout)

                    -- Exit animation
                    if Exit ~= nil then
                        if type(Exit) == 'table' then
                            if Exit.Duration == nil then
                                Exit.Duration = Interval
                            end
                            AnimateUI[Exit.Effect](Message, Settings, Exit.Duration, 0, Callback)
                        elseif type(Exit) == 'string' then
                            AnimateUI[Exit](Message, Settings, Interval, 0, Callback)
                        end
                        Citizen.Wait(10)
                        Thread.Tick = false
                        Threads[Index] = nil
                        break
                    else
                        Thread.Tick = false
                        Threads[Index] = nil
                        
                        if Callback ~= nil then
                            Callback()
                        end
                    end 
                end
            end
            Citizen.Wait(Interval)
        end
    end)

    Citizen.CreateThread(function()
        while Thread.Tick do
            AnimateUI.RenderMessage(Str, Copy.PositionX, Copy.PositionY, Copy.Size, Copy.Font, Copy.Opacity)
            Citizen.Wait(0)
        end
    end) 
    
    return ID
end

AnimateUI.discordOut = function(Message, Settings, Interval, Timeout, cb)
    local Length = string.len(Message)
    local Count = Length
    local Copy = {
        Font         = Config.Font,
        Size         = Config.Size,
        PositionX    = Config.PositionX,
        PositionY    = Config.PositionY,
        Opacity      = Config.Opacity
    }

    if Settings ~= nil then
        Copy = MergeConfig(Copy, Settings)
    end

    local Index = #Threads + 1
    local ID = RandomID(20)
    table.insert(Threads, Index, {
        Tick = true,
        ID = ID
    })

    local Thread = Threads[Index]

    Citizen.CreateThread(function()
        while Thread.Tick do
            if Count > 0 then
                Count = Count - 1
                Str = string.sub(Message, 0, Count)

                if Count == 0 then
                    Citizen.Wait(Timeout)

                    Thread.Tick = false
                    Threads[Index] = nil

                    Count = 0

                    if cb ~= nil then
                        cb()
                    end
                end
            end
            Citizen.Wait(Interval)
        end
    end)

    Citizen.CreateThread(function()
        while Thread.Tick do
            AnimateUI.RenderMessage(Str, Copy.PositionX, Copy.PositionY, Copy.Size, Copy.Font, Copy.Opacity)
            Citizen.Wait(0)
        end
    end)    

    return ID
end

-- Ägare effekten

AnimateUI.ownerIn = function(Message, Settings, Interval, Timeout, Exit, Callback)
    local Count = 0
    local Length = string.len(Message)

    local Copy = {
        Font         = Config.Font,
        Size         = Config.Size,
        PositionX    = Config.PositionX,
        PositionY    = Config.PositionY,
        Opacity      = Config.Opacity
    }

    if Settings ~= nil then
        Copy = MergeConfig(Copy, Settings)
    end

    local Index = #Threads + 1
    local ID = RandomID(20)
    table.insert(Threads, Index, {
        Tick = true,
        ID = ID
    })

    local Thread = Threads[Index]

    Citizen.CreateThread(function()
        while Thread.Tick do
            if Count < Length then
                Count = Count + 1
                Str = string.sub(Message, 0, Count)

                if Count == Length then
                    Citizen.Wait(Timeout)

                    -- Exit animation
                    if Exit ~= nil then
                        if type(Exit) == 'table' then
                            if Exit.Duration == nil then
                                Exit.Duration = Interval
                            end
                            AnimateUI[Exit.Effect](Message, Settings, Exit.Duration, 0, Callback)
                        elseif type(Exit) == 'string' then
                            AnimateUI[Exit](Message, Settings, Interval, 0, Callback)
                        end
                        Citizen.Wait(10)
                        Thread.Tick = false
                        Threads[Index] = nil
                        break
                    else
                        Thread.Tick = false
                        Threads[Index] = nil
                        
                        if Callback ~= nil then
                            Callback()
                        end
                    end 
                end
            end
            Citizen.Wait(Interval)
        end
    end)

    Citizen.CreateThread(function()
        while Thread.Tick do
            AnimateUI.RenderMessage(Str, Copy.PositionX, Copy.PositionY, Copy.Size, Copy.Font, Copy.Opacity)
            Citizen.Wait(0)
        end
    end) 
    
    return ID
end

AnimateUI.ownerOut = function(Message, Settings, Interval, Timeout, cb)
    local Length = string.len(Message)
    local Count = Length
    local Copy = {
        Font         = Config.Font,
        Size         = Config.Size,
        PositionX    = Config.PositionX,
        PositionY    = Config.PositionY,
        Opacity      = Config.Opacity
    }

    if Settings ~= nil then
        Copy = MergeConfig(Copy, Settings)
    end

    local Index = #Threads + 1
    local ID = RandomID(20)
    table.insert(Threads, Index, {
        Tick = true,
        ID = ID
    })

    local Thread = Threads[Index]

    Citizen.CreateThread(function()
        while Thread.Tick do
            if Count > 0 then
                Count = Count - 1
                Str = string.sub(Message, 0, Count)

                if Count == 0 then
                    Citizen.Wait(Timeout)

                    Thread.Tick = false
                    Threads[Index] = nil

                    Count = 0

                    if cb ~= nil then
                        cb()
                    end
                end
            end
            Citizen.Wait(Interval)
        end
    end)

    Citizen.CreateThread(function()
        while Thread.Tick do
            AnimateUI.RenderMessage(Str, Copy.PositionX, Copy.PositionY, Copy.Size, Copy.Font, Copy.Opacity)
            Citizen.Wait(0)
        end
    end)    

    return ID
end

-- utvekclare effekten

AnimateUI.devIn = function(Message, Settings, Interval, Timeout, Exit, Callback)
    local Count = 0
    local Length = string.len(Message)

    local Copy = {
        Font         = Config.Font,
        Size         = Config.Size,
        PositionX    = Config.PositionX,
        PositionY    = Config.PositionY,
        Opacity      = Config.Opacity
    }

    if Settings ~= nil then
        Copy = MergeConfig(Copy, Settings)
    end

    local Index = #Threads + 1
    local ID = RandomID(20)
    table.insert(Threads, Index, {
        Tick = true,
        ID = ID
    })

    local Thread = Threads[Index]

    Citizen.CreateThread(function()
        while Thread.Tick do
            if Count < Length then
                Count = Count + 1
                Str = string.sub(Message, 0, Count)

                if Count == Length then
                    Citizen.Wait(Timeout)

                    -- Exit animation
                    if Exit ~= nil then
                        if type(Exit) == 'table' then
                            if Exit.Duration == nil then
                                Exit.Duration = Interval
                            end
                            AnimateUI[Exit.Effect](Message, Settings, Exit.Duration, 0, Callback)
                        elseif type(Exit) == 'string' then
                            AnimateUI[Exit](Message, Settings, Interval, 0, Callback)
                        end
                        Citizen.Wait(10)
                        Thread.Tick = false
                        Threads[Index] = nil
                        break
                    else
                        Thread.Tick = false
                        Threads[Index] = nil
                        
                        if Callback ~= nil then
                            Callback()
                        end
                    end 
                end
            end
            Citizen.Wait(Interval)
        end
    end)

    Citizen.CreateThread(function()
        while Thread.Tick do
            AnimateUI.RenderMessage(Str, Copy.PositionX, Copy.PositionY, Copy.Size, Copy.Font, Copy.Opacity)
            Citizen.Wait(0)
        end
    end) 
    
    return ID
end

AnimateUI.devOut = function(Message, Settings, Interval, Timeout, cb)
    local Length = string.len(Message)
    local Count = Length
    local Copy = {
        Font         = Config.Font,
        Size         = Config.Size,
        PositionX    = Config.PositionX,
        PositionY    = Config.PositionY,
        Opacity      = Config.Opacity
    }

    if Settings ~= nil then
        Copy = MergeConfig(Copy, Settings)
    end

    local Index = #Threads + 1
    local ID = RandomID(20)
    table.insert(Threads, Index, {
        Tick = true,
        ID = ID
    })

    local Thread = Threads[Index]

    Citizen.CreateThread(function()
        while Thread.Tick do
            if Count > 0 then
                Count = Count - 1
                Str = string.sub(Message, 0, Count)

                if Count == 0 then
                    Citizen.Wait(Timeout)

                    Thread.Tick = false
                    Threads[Index] = nil

                    Count = 0

                    if cb ~= nil then
                        cb()
                    end
                end
            end
            Citizen.Wait(Interval)
        end
    end)

    Citizen.CreateThread(function()
        while Thread.Tick do
            AnimateUI.RenderMessage(Str, Copy.PositionX, Copy.PositionY, Copy.Size, Copy.Font, Copy.Opacity)
            Citizen.Wait(0)
        end
    end)    

    return ID
end