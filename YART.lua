SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
})

---Modify cards with the tarot animation
---@param targets Card[]
---@param modification fun(card: Card): nil
local function modify_cards(targets, modification)
    ---@type table<Card, true>
    local hand_set = {}
    for _, card in ipairs(G.hand.cards) do
        hand_set[card] = true
    end
    ---@type Card[]
    local hand_targets = {}
    for _, target in ipairs(targets) do
        if hand_set[target] then
            table.insert(hand_targets, target)
        else
            modification(target)
        end
    end
    for i, target in ipairs(hand_targets) do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('card1', 1.15 - (i - 0.999) / (#hand_targets - 0.998) * 0.3)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    delay(0.2)
    for i, target in ipairs(hand_targets) do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                modification(target)
                return true
            end
        }))
    end
    for i, target in ipairs(hand_targets) do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                target:flip()
                play_sound('tarot2', 0.85 + (i - 0.999) / (#hand_targets - 0.998) * 0.3, 0.6)
                target:juice_up(0.3, 0.3)
                return true
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
end

---@class Colour [number, number, number, number]

---@param card Card
---@param colour Colour
local function nope(card, colour)
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.4,
        func = function() --"borrowed" from Wheel Of Fortune
            attention_text({
                text = localize("k_nope_ex"),
                scale = 1.3,
                hold = 1.4,
                major = card,
                backdrop_colour = colour,
                align = (
                        G.STATE == G.STATES.TAROT_PACK
                        or G.STATE == G.STATES.SPECTRAL_PACK
                        or G.STATE == G.STATES.SMODS_BOOSTER_OPENED
                    )
                    and "tm"
                    or "cm",
                offset = {
                    x = 0,
                    y = (
                            G.STATE == G.STATES.TAROT_PACK
                            or G.STATE == G.STATES.SPECTRAL_PACK
                            or G.STATE == G.STATES.SMODS_BOOSTER_OPENED
                        )
                        and -0.2
                        or 0,
                },
                silent = true,
            })
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.06 * G.SETTINGS.GAMESPEED,
                blockable = false,
                blocking = false,
                func = function()
                    play_sound("tarot2", 0.76, 0.4)
                    return true
                end,
            }))
            play_sound("tarot2", 1, 0.4)
            card:juice_up(0.3, 0.5)
            return true
        end,
    }))
end

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
    loc_vars = function(self, info_queue, card)
        if G.GAME.yart_last_other then
            table.insert(info_queue, G.P_CENTERS[G.GAME.yart_last_other])
        end
        return {
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", padding = 0.02 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "m", colour = G.GAME.yart_last_other and G.C.GREEN or G.C.RED, r = 0.05, padding = 0.05 },
                            nodes = {
                                {
                                    n = G.UIT.T,
                                    config = {
                                        text = " " ..
                                            (G.GAME.yart_last_other and localize { type = "name_text", key = G.GAME.yart_last_other, set = G.P_CENTERS[G.GAME.yart_last_other].set } or localize("k_none"))
                                            .. " ",
                                        colour = G.C.UI.TEXT_LIGHT,
                                        scale = 0.3,
                                        shadow = true
                                    }
                                },
                            }
                        }
                    }
                }
            }
        }
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables)
            and G.GAME.yart_last_other
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ key = G.GAME.yart_last_other })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
})
SMODS.Consumable({
    key = "rmagician",
    set = "Tarot",
    pos = { x = 1, y = 0 },
    atlas = "rtarots",
    config = { chance = 7 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_lucky)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = function(self, card)
        return #G.hand.cards ~= 0
    end,
    use = function(self, card, area)
        if pseudorandom('rmagician') < G.GAME.probabilities.normal / card.ability.chance then
            modify_cards(G.hand.cards, function(target)
                target:set_ability(G.P_CENTERS.m_lucky)
            end)
        else
            nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
})
SMODS.Consumable({
    key = "rhigh_priestess",
    set = "Tarot",
    pos = { x = 2, y = 0 },
    atlas = "rtarots",
    config = { chance = 2 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_TAGS.tag_meteor)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = function(self, card)
        return true
    end,
    can_bulk_use = true,
    use = function(self, card, area)
        if pseudorandom('rhigh_priestess') < G.GAME.probabilities.normal / card.ability.chance then
            add_tag(Tag("tag_meteor"))
        else
            nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
})
SMODS.Consumable({
    key = "rempress",
    set = "Tarot",
    pos = { x = 3, y = 0 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_mult)
        table.insert(info_queue, G.P_CENTERS.m_bonus)
    end,
    can_use = function(self, card)
        local has_bonus = false
        local has_mult = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_bonus") then
                    has_bonus = true
                elseif SMODS.has_enhancement(v, "m_mult") then
                    has_mult = true
                end
            end
        end
        return has_bonus and has_mult
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local mult = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_mult") then
                table.insert(mult, v)
            end
        end
        mult = pseudorandom_element(mult, pseudoseed('rempress'))
        local bonus = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_bonus") then
                table.insert(bonus, v)
            end
        end
        for i = 1, #bonus do
            local percent = 1.15 - (i - 0.999) / (#bonus - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    bonus[i]:flip(); play_sound('card1', percent); bonus[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #bonus do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(mult, bonus[i])
                    return true
                end
            }))
        end
        for i = 1, #bonus do
            local percent = 0.85 + (i - 0.999) / (#bonus - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    bonus[i]:flip(); play_sound('tarot2', percent, 0.6); bonus[i]:juice_up(0.3, 0.3); return true
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
    key = "remperor",
    set = "Tarot",
    pos = { x = 4, y = 0 },
    atlas = "rtarots",
    config = { chance = 2 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_TAGS.tag_charm)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = function(self, card)
        return true
    end,
    can_bulk_use = true,
    use = function(self, card, area)
        if pseudorandom('remperor') < G.GAME.probabilities.normal / card.ability.chance then
            add_tag(Tag("tag_charm"))
        else
            nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
})
SMODS.Consumable({
    key = "rheirophant",
    set = "Tarot",
    pos = { x = 0, y = 1 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_bonus)
        table.insert(info_queue, G.P_CENTERS.m_mult)
    end,
    can_use = function(self, card)
        local has_mult = false
        local has_bonus = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_mult") then
                    has_mult = true
                elseif SMODS.has_enhancement(v, "m_bonus") then
                    has_bonus = true
                end
            end
        end
        return has_mult and has_bonus
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local bonus = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_bonus") then
                table.insert(bonus, v)
            end
        end
        bonus = pseudorandom_element(bonus, pseudoseed('rheirophant'))
        local mult = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_mult") then
                table.insert(mult, v)
            end
        end
        for i = 1, #mult do
            local percent = 1.15 - (i - 0.999) / (#mult - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    mult[i]:flip(); play_sound('card1', percent); mult[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #mult do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(bonus, mult[i])
                    return true
                end
            }))
        end
        for i = 1, #mult do
            local percent = 0.85 + (i - 0.999) / (#mult - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    mult[i]:flip(); play_sound('tarot2', percent, 0.6); mult[i]:juice_up(0.3, 0.3); return true
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
    key = "rlovers",
    set = "Tarot",
    pos = { x = 1, y = 1 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_wild)
        table.insert(info_queue, G.P_CENTERS.m_stone)
    end,
    can_use = function(self, card)
        local has_stone = false
        local has_wild = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_stone") then
                    has_stone = true
                elseif SMODS.has_enhancement(v, "m_wild") then
                    has_wild = true
                end
            end
        end
        return has_stone and has_wild
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local wild = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_wild") then
                table.insert(wild, v)
            end
        end
        wild = pseudorandom_element(wild, pseudoseed('rlovers'))
        local stone = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_stone") then
                table.insert(stone, v)
            end
        end
        for i = 1, #stone do
            local percent = 1.15 - (i - 0.999) / (#stone - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    stone[i]:flip(); play_sound('card1', percent); stone[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #stone do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(wild, stone[i])
                    return true
                end
            }))
        end
        for i = 1, #stone do
            local percent = 0.85 + (i - 0.999) / (#stone - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    stone[i]:flip(); play_sound('tarot2', percent, 0.6); stone[i]:juice_up(0.3, 0.3); return true
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
    key = "rchariot",
    set = "Tarot",
    pos = { x = 2, y = 1 },
    atlas = "rtarots",
    config = { extra = get_starting_params().hand_size },
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.extra = G.GAME and G.GAME.starting_params.hand_size or self.config.extra
    end,
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_steel)
        return { vars = { card.ability.extra, G.hand and math.max(G.hand.config.card_limit - card.ability.extra, 0) or 0 } }
    end,
    can_use = function(self, card)
        return #G.hand.cards > 0 and G.hand.config.card_limit > card.ability.extra
    end,
    use = function(self, card, area)
        ---@type Card[]
        local modification_list
        if #G.hand.cards < G.hand.config.card_limit - card.ability.extra then
            modification_list = G.hand.cards
            for _ = 1, #G.hand.cards do
                pseudoseed("rchariot")
            end
        else
            modification_list = {}
            ---@type table<Card, true>
            local targets = {}
            ---@type Card[]
            local valid_targets = {}
            for i, hand_card in ipairs(G.hand.cards) do
                valid_targets[i] = hand_card
            end
            for _ = 1, G.hand.config.card_limit - card.ability.extra do
                ---@type Card
                local new_target = pseudorandom_element(valid_targets, pseudoseed("rchariot")) --[[@as Card]]
                targets[new_target] = true
                for i, held_card in ipairs(valid_targets) do
                    if held_card == new_target then
                        table.remove(valid_targets, i)
                        break
                    end
                end
            end
            for _, hand_card in ipairs(G.hand.cards) do
                if targets[hand_card] then
                    table.insert(modification_list, hand_card)
                end
            end
        end
        modify_cards(modification_list, function(target)
            target:set_ability(G.P_CENTERS.m_steel)
        end)
    end,
})
SMODS.Consumable({
    key = "rjustice",
    set = "Tarot",
    pos = { x = 3, y = 1 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_glass)
        table.insert(info_queue, G.P_CENTERS.m_lucky)
    end,
    can_use = function(self, card)
        local has_lucky = false
        local has_glass = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_lucky") then
                    has_lucky = true
                elseif SMODS.has_enhancement(v, "m_glass") then
                    has_glass = true
                end
            end
        end
        return has_lucky and has_glass
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local glass = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_glass") then
                table.insert(glass, v)
            end
        end
        glass = pseudorandom_element(glass, pseudoseed('rjustice'))
        local lucky = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_lucky") then
                table.insert(lucky, v)
            end
        end
        for i = 1, #lucky do
            local percent = 1.15 - (i - 0.999) / (#lucky - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    lucky[i]:flip(); play_sound('card1', percent); lucky[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #lucky do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(glass, lucky[i])
                    return true
                end
            }))
        end
        for i = 1, #lucky do
            local percent = 0.85 + (i - 0.999) / (#lucky - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    lucky[i]:flip(); play_sound('tarot2', percent, 0.6); lucky[i]:juice_up(0.3, 0.3); return true
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
    key = "rhermit",
    set = "Tarot",
    pos = { x = 4, y = 1 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.last_cash_out or G.GAME.starting_params.dollars } }
    end,
    in_pool = function(self, args)
        return G.GAME.last_cash_out ~= nil
    end,
    can_use = function(self, card)
        return G.GAME.last_cash_out ~= nil
    end,
    can_bulk_use = true,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                card:juice_up(0.3, 0.5)
                ease_dollars(G.GAME.last_cash_out, true)
                return true
            end
        }))
        delay(0.6)
    end,
    bulk_use = function(self, card, area, number)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                card:juice_up(0.3, 0.5)
                ease_dollars(G.GAME.last_cash_out * number, true)
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
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.e_negative)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = function(self, card)
        for k, v in pairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and (not v.edition) then
                return true
            end
        end
    end,
    use = function(self, card, area)
        if pseudorandom('rwheel_of_fortune') < G.GAME.probabilities.normal / card.ability.chance then
            ---@type Card[]
            local pool = {}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and (not v.edition) then
                    table.insert(pool, v)
                end
            end
            ---@type Card
            local selected = pseudorandom_element(pool, pseudoseed("rwheel_of_fortune")) --[[@as Card]]
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
            ---@type Card[]
            local pool = {}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and (not v.ability.eternal) then
                    table.insert(pool, v)
                end
            end
            if #pool ~= 0 then
                ---@type Card
                local selected = pseudorandom_element(pool, pseudoseed("rwheel_of_fortune")) --[[@as Card]]
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
    key = "rstrength",
    set = "Tarot",
    pos = { x = 0, y = 2 },
    atlas = "rtarots",
    config = { limit = 3 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.limit } }
    end,
    can_use = function(self, card)
        return #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.limit
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        ---@type string[]
        local ranks = {}
        for k, v in ipairs(G.playing_cards) do
            if not SMODS.has_no_rank(v) then
                table.insert(ranks, v.base.value)
            end
        end
        ---@type string
        local rank = pseudorandom_element(ranks, pseudoseed('rStrength')) --[[@as string]]
        delay(0.2)
        modify_cards(G.hand.highlighted, function(target)
            SMODS.change_base(target, nil, rank)
        end)
    end,
})
SMODS.Consumable({
    key = "rhanged_man",
    set = "Tarot",
    pos = { x = 1, y = 2 },
    atlas = "rtarots",
    can_use = function(self, card)
        return #G.hand.cards > 0
    end,
    use = function(self, card, area)
        ---@type Card[]
        local destroy = {}
        if pseudorandom('rhanged_man') < 0.5 then
            for k, v in ipairs(G.hand.highlighted) do
                table.insert(destroy, v)
            end
        else
            for k, v in ipairs(G.hand.cards) do
                ---@type boolean
                local highlighted = false
                for hk, hv in ipairs(G.hand.highlighted) do
                    if v == hv then
                        highlighted = true
                        break
                    end
                end
                if not highlighted then
                    table.insert(destroy, v)
                end
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                for k, v in ipairs(destroy) do
                    if v.ability.name == 'm_glass' then
                        v:shatter()
                    else
                        v:start_dissolve()
                    end
                end
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
})
SMODS.Consumable({
    key = "rdeath",
    set = "Tarot",
    pos = { x = 2, y = 2 },
    atlas = "rtarots",
    config = { limit = 3 },
    loc_vars = function(self, info_queue, card)
        local rightmost = nil
        if G.hand and G.hand.highlighted and #G.hand.highlighted > 0 then
            rightmost = G.hand.highlighted[1]
            for k, v in ipairs(G.hand.highlighted) do
                if v.T.x > rightmost.T.x then
                    rightmost = v
                end
            end
        end
        return { vars = { card.ability.limit, rightmost and rightmost:get_chip_bonus() or 0 } }
    end,
    can_use = function(self, card)
        local rightmost = nil
        if #G.hand.highlighted > 0 then
            rightmost = G.hand.highlighted[1]
            for k, v in ipairs(G.hand.highlighted) do
                if v.T.x > rightmost.T.x then
                    rightmost = v
                end
            end
        end
        return #G.hand.highlighted >= 2 and #G.hand.highlighted <= card.ability.limit and
            StrangeLib.safe_compare(G.GAME.dollars - rightmost:get_chip_bonus() -
                ((card.area == G.shop_jokers or card.area == G.shop_booster or card.area == G.shop_vouchers) and card.cost or 0),
                ">=", G.GAME.bankrupt_at)
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip(); play_sound('card1', percent); G.hand.highlighted[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        local rightmost = G.hand.highlighted[1]
        for k, v in ipairs(G.hand.highlighted) do
            if v.T.x > rightmost.T.x then
                rightmost = v
            end
        end
        for k, v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if v ~= rightmost then
                        copy_card(rightmost, v)
                    end
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                card:juice_up(0.3, 0.5)
                ease_dollars(-rightmost:get_chip_bonus(), true)
                return true
            end
        }))
        delay(0.6)
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(0.3,
                        0.3); return true
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
    key = "rtemperance",
    set = "Tarot",
    pos = { x = 3, y = 2 },
    atlas = "rtarots",
    config = { extra = 25, factor = 1 },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.consumeable_usage_total and math.max(G.GAME.consumeable_usage_total.all * card.ability.factor, card.ability.extra) or 0, card.ability.factor, card.ability.extra } }
    end,
    can_use = function(self, card)
        return true
    end,
    can_bulk_use = true,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                card:juice_up(0.3, 0.5)
                ease_dollars(math.max(G.GAME.consumeable_usage_total.all * card.ability.factor, card.ability.extra), true)
                return true
            end
        }))
        delay(0.6)
    end,
    bulk_use = function(self, card, area, number)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                card:juice_up(0.3, 0.5)
                ease_dollars(
                    math.max(G.GAME.consumeable_usage_total.all * card.ability.factor, card.ability.extra) * number, true)
                return true
            end
        }))
        delay(0.6)
    end,
})
SMODS.Consumable({
    key = "rdevil",
    set = "Tarot",
    pos = { x = 4, y = 2 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_gold)
        table.insert(info_queue, G.P_CENTERS.m_steel)
    end,
    can_use = function(self, card)
        local has_steel = false
        local has_gold = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_steel") then
                    has_steel = true
                elseif SMODS.has_enhancement(v, "m_gold") then
                    has_gold = true
                end
            end
        end
        return has_steel and has_gold
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local gold = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_gold") then
                table.insert(gold, v)
            end
        end
        gold = pseudorandom_element(gold, pseudoseed('rdevil'))
        local steel = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_steel") then
                table.insert(steel, v)
            end
        end
        for i = 1, #steel do
            local percent = 1.15 - (i - 0.999) / (#steel - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    steel[i]:flip(); play_sound('card1', percent); steel[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #steel do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(gold, steel[i])
                    return true
                end
            }))
        end
        for i = 1, #steel do
            local percent = 0.85 + (i - 0.999) / (#steel - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    steel[i]:flip(); play_sound('tarot2', percent, 0.6); steel[i]:juice_up(0.3, 0.3); return true
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
    key = "rtower",
    set = "Tarot",
    pos = { x = 0, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_stone)
        table.insert(info_queue, G.P_CENTERS.m_wild)
    end,
    can_use = function(self, card)
        local has_wild = false
        local has_stone = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_wild") then
                    has_wild = true
                elseif SMODS.has_enhancement(v, "m_stone") then
                    has_stone = true
                end
            end
        end
        return has_wild and has_stone
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        local stone = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_stone") then
                table.insert(stone, v)
            end
        end
        stone = pseudorandom_element(stone, pseudoseed('rtower'))
        local wild = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_wild") then
                table.insert(wild, v)
            end
        end
        for i = 1, #wild do
            local percent = 1.15 - (i - 0.999) / (#wild - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    wild[i]:flip(); play_sound('card1', percent); wild[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #wild do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(stone, wild[i])
                    return true
                end
            }))
        end
        for i = 1, #wild do
            local percent = 0.85 + (i - 0.999) / (#wild - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    wild[i]:flip(); play_sound('tarot2', percent, 0.6); wild[i]:juice_up(0.3, 0.3); return true
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
    key = "rstar",
    set = "Tarot",
    pos = { x = 1, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
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
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        ---@type Card[]
        local diamonds = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Diamonds") then
                table.insert(diamonds, v)
            end
        end
        modify_cards(diamonds, function(target)
            target:set_ability(G.P_CENTERS.m_gold)
        end)
    end,
})
SMODS.Consumable({
    key = "rmoon",
    set = "Tarot",
    pos = { x = 2, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
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
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        ---@type Card[]
        local clubs = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Clubs") then
                table.insert(clubs, v)
            end
        end
        modify_cards(clubs, function(target)
            target:set_ability(G.P_CENTERS.m_mult)
        end)
    end,
})
SMODS.Consumable({
    key = "rsun",
    set = "Tarot",
    pos = G.localization.descriptions.Tarot.c_sun.name == "The Sus" and { x = 5, y = 2 } or { x = 3, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
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
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        ---@type Card[]
        local hearts = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Hearts") then
                table.insert(hearts, v)
            end
        end
        modify_cards(hearts, function(target)
            target:set_ability(G.P_CENTERS.m_glass)
        end)
    end,
})
SMODS.Consumable({
    key = "rjudgement",
    set = "Tarot",
    pos = { x = 4, y = 3 },
    atlas = "rtarots",
    config = { chance = 3 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_TAGS.tag_buffoon)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = function(self, card)
        return true
    end,
    can_bulk_use = true,
    use = function(self, card, area)
        if pseudorandom('rjudgement') < G.GAME.probabilities.normal / card.ability.chance then
            add_tag(Tag("tag_buffoon"))
        else
            nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
})
SMODS.Consumable({
    key = "rworld",
    set = "Tarot",
    pos = { x = 5, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
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
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        ---@type Card[]
        local spades = {}
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Spades") then
                table.insert(spades, v)
            end
        end
        modify_cards(spades, function(target)
            target:set_ability(G.P_CENTERS.m_bonus)
        end)
    end,
})

StrangeLib.bulk_add(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, {
    { id = "c_yart_rmagician" },
    { id = "c_yart_rempress" },
    { id = "c_yart_rheirophant" },
    { id = "c_yart_rlovers" },
    { id = "c_yart_rchariot" },
    { id = "c_yart_rdevil" },
    { id = "c_yart_rtower" },
    { id = "c_yart_rstar" },
    { id = "c_yart_rmoon" },
    { id = "c_yart_rworld" },
})
table.insert(SMODS.Challenges.c_jokerless_1.restrictions.banned_cards, 2, { id = "c_yart_rjudgement" })

if (SMODS.Mods["sun_is_sus"] or {}).can_load then
    AltTexture({
        key = "rsus",
        set = "Tarot",
        path = "rsus.png",
        keys = {
            "c_yart_rsun"
        },
        localization = {
            "c_yart_rsun"
        }
    })
    table.insert(TexturePacks.texpack_sus_sus.textures, "yart_rsus")
end
