-- Discord funktion --

function InitdiscordAnimations(loop)
    AnimateUI.discordIn("Discord: https://discord.gg/9p5YnRubw5", nil, 100, 50000, nil, function()
        if loop then
            InitZoomAnimations(loop)
        end
    end)
end

function InitDemo()
    InitdiscordAnimations(true)
end

-- Ägare funktion --

function InitownerAnimations(loop)
    AnimateUI.ownerIn("Ägare: Force, Zyke & Supra", nil, 100, 10000, nil, function()
        if loop then
            InitZoomAnimations(loop)
        end
    end)
end

function InitDemo()
    InitownerAnimations(true)
end

-- Utvecklare funktion --

function InitdevAnimations(loop)
    AnimateUI.devIn("Utvecklare: Force & Zyke", nil, 100, 10000, nil, function()
        if loop then
            InitZoomAnimations(loop)
        end
    end)
end

function InitDemo()
    InitdevAnimations(true)
end