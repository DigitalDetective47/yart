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
    key = "rfool",
    set = "Tarot",
    pos = { x = 0, y = 0 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, center)
        local fool_c = G.GAME.yart_last_other and G.P_CENTERS[G.GAME.yart_last_other] or nil
        local yart_last_other = fool_c and localize { type = 'name_text', key = fool_c.key, set = fool_c.set } or
            localize('k_none')
        local colour = (not fool_c) and G.C.RED or G.C.GREEN
        main_end = {
            {
                n = G.UIT.C,
                config = { align = "bm", padding = 0.02 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "m", colour = colour, r = 0.05, padding = 0.05 },
                        nodes = {
                            { n = G.UIT.T, config = { text = ' ' .. yart_last_other .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true } },
                        }
                    }
                }
            }
        }
        if not (not fool_c) then
            info_queue[#info_queue + 1] = fool_c
        end
        return { main_end = main_end }
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or self.area == G.consumeables)
            and G.GAME.yart_last_other
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                local card = create_card(nil, G.consumeables, nil, nil, nil, nil, G.GAME.yart_last_other)
                card:add_to_deck()
                G.consumeables:emplace(card)
                used_tarot:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
})
SMODS.Consumable({
    key = "rwheel_of_fortune",
    set = "Tarot",
    pos = { x = 5, y = 1 },
    atlas = "rtarots",
    config = { chance = 4 },
    loc_vars = function(self, info_queue, center)
        table.insert(info_queue, G.P_CENTERS.e_negative)
        return { vars = { G.GAME.probabilities.normal, self.config.chance } }
    end,
    can_use = function(self, card)
        for k, v in pairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and (not v.edition) then
                return true
            end
        end
    end,
    use = function(self, card, area, copier)
        if pseudorandom('rwheel_of_fortune') < G.GAME.probabilities.normal / self.config.chance then
            local pool = {}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and (not v.edition) then
                    table.insert(pool, v)
                end
            end
            local selected = pseudorandom_element(pool, pseudoseed("rwheel_of_fortune"))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    selected:set_edition("e_negative")
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        else
            local pool = {}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and (not v.ability.eternal) then
                    table.insert(pool, v)
                end
            end
            if #pool ~= 0 then
                local selected = pseudorandom_element(pool, pseudoseed("rwheel_of_fortune"))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        selected:start_dissolve()
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
        end
    end,
})
SMODS.Consumable({
    key = "rtemperance",
    set = "Tarot",
    pos = { x = 3, y = 2 },
    atlas = "rtarots",
    config = { multiplier = 2, maximum = 50 },
    loc_vars = function(self, info_queue, center)
        local value = 0
        if G.consumeables then
            for k, v in pairs(G.consumeables.cards) do
                if v ~= self then
                    value = value + v.sell_cost
                end
            end
        end
        return { vars = { (self.config.multiplier == 2) and "double" or ("X" .. self.config.multiplier), self.config.maximum, value } }
    end,
    can_use = function(self, card)
        return #G.consumeables.cards >= 1
    end,
    use = function(self, card, area, copier)
        local value = 0
        for k, v in pairs(G.consumeables.cards) do
            if v ~= self then
                value = value + v.sell_cost
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                ease_dollars(value, true)
                return true
            end
        }))
        delay(0.6)
    end,
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
