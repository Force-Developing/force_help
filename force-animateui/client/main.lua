function showMessage(Message, Type, Interval, Timeout, Settings, Exit, Callback)
    if AnimateUI[Type] then
        return AnimateUI[Type](Message, Interval, Timeout, Settings, Exit, Callback)
    end

    return false
end

function removeMessage(ID)
    AnimateUI.Kill(ID)
end

TriggerEvent('chat:addSuggestion', '/hjälp', 'help text', {
    { name="type", help="discord I ägare I utvecklare" }
}) 

RegisterCommand('hjälp', function(source, args)
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        if args ~= nil then
            if args[1] == 'discord' then
                InitdiscordAnimations()
            elseif args[1] == 'ägare' then
                    InitownerAnimations()
                elseif args[1] == 'utvecklare' then
                    InitdevAnimations()
            end
        end  
    end)
end)