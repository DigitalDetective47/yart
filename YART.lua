--- STEAMODDED HEADER
--- MOD_NAME: Yet Another Reversed Tarot mod
--- MOD_ID: YART
--- MOD_AUTHOR: [DigitalDetective47]
--- MOD_DESCRIPTION: A Balatro mod that adds reversed tarot cards to the game
--- DISPLAY_NAME: YART
--- BADGE_COLOR: A782D1
--- PREFIX: yart

SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
})

SMODS.Atlas({
    key = "rtarots",
    path = "tarot.png",
    px = 71,
    py = 95,
})
SMODS.Consumable({
    key = "rstar",
    set = "Tarot",
    pos = { x = 1, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, center)
        table.insert(info_queue, G.P_CENTERS.m_gold)
    end,
    can_use = function(self, card)
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if v:is_suit("Diamonds") then
                    return true
                end
            end
        end
        return false
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local diamonds = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Diamonds") then
                table.insert(diamonds, v)
            end
        end
        for i = 1, #diamonds do
            local percent = 1.15 - (i - 0.999) / (#diamonds - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    diamonds[i]:flip(); play_sound('card1', percent); diamonds[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #diamonds do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    diamonds[i]:set_ability(G.P_CENTERS.m_gold)
                    return true
                end
            }))
        end
        for i = 1, #diamonds do
            local percent = 0.85 + (i - 0.999) / (#diamonds - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    diamonds[i]:flip(); play_sound('tarot2', percent, 0.6); diamonds[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all(); return true
            end
        }))
        delay(0.5)
    end,
})
SMODS.Consumable({
    key = "rmoon",
    set = "Tarot",
    pos = { x = 2, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, center)
        table.insert(info_queue, G.P_CENTERS.m_mult)
    end,
    can_use = function(self, card)
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if v:is_suit("Clubs") then
                    return true
                end
            end
        end
        return false
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local clubs = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Clubs") then
                table.insert(clubs, v)
            end
        end
        for i = 1, #clubs do
            local percent = 1.15 - (i - 0.999) / (#clubs - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    clubs[i]:flip(); play_sound('card1', percent); clubs[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #clubs do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    clubs[i]:set_ability(G.P_CENTERS.m_mult)
                    return true
                end
            }))
        end
        for i = 1, #clubs do
            local percent = 0.85 + (i - 0.999) / (#clubs - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    clubs[i]:flip(); play_sound('tarot2', percent, 0.6); clubs[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all(); return true
            end
        }))
        delay(0.5)
    end,
})
SMODS.Consumable({
    key = "rsun",
    set = "Tarot",
    pos = { x = 3, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, center)
        table.insert(info_queue, G.P_CENTERS.m_glass)
    end,
    can_use = function(self, card)
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if v:is_suit("Hearts") then
                    return true
                end
            end
        end
        return false
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local hearts = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Hearts") then
                table.insert(hearts, v)
            end
        end
        for i = 1, #hearts do
            local percent = 1.15 - (i - 0.999) / (#hearts - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    hearts[i]:flip(); play_sound('card1', percent); hearts[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #hearts do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    hearts[i]:set_ability(G.P_CENTERS.m_glass)
                    return true
                end
            }))
        end
        for i = 1, #hearts do
            local percent = 0.85 + (i - 0.999) / (#hearts - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    hearts[i]:flip(); play_sound('tarot2', percent, 0.6); hearts[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all(); return true
            end
        }))
        delay(0.5)
    end,
})
SMODS.Consumable({
    key = "rworld",
    set = "Tarot",
    pos = { x = 5, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, center)
        table.insert(info_queue, G.P_CENTERS.m_bonus)
    end,
    can_use = function(self, card)
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if v:is_suit("Spades") then
                    return true
                end
            end
        end
        return false
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local spades = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Spades") then
                table.insert(spades, v)
            end
        end
        for i = 1, #spades do
            local percent = 1.15 - (i - 0.999) / (#spades - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    spades[i]:flip(); play_sound('card1', percent); spades[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #spades do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    spades[i]:set_ability(G.P_CENTERS.m_bonus)
                    return true
                end
            }))
        end
        for i = 1, #spades do
            local percent = 0.85 + (i - 0.999) / (#spades - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    spades[i]:flip(); play_sound('tarot2', percent, 0.6); spades[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all(); return true
            end
        }))
        delay(0.5)
    end,
})
