SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
})

function defaultBulkUse(self, card, area, copier, number)
    for i = 1, number, 1 do
        self:use(card, area, copier)
    end
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
        if fool_c then
            table.insert(info_queue, fool_c)
        end
        return { main_end = main_end }
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables)
            and G.GAME.yart_last_other
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                local new = create_card(nil, G.consumeables, nil, nil, nil, nil, G.GAME.yart_last_other)
                new:add_to_deck()
                G.consumeables:emplace(new)
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
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_lucky)
        table.insert(info_queue, G.P_CENTERS.m_glass)
    end,
    can_use = function(self, card)
        local has_glass = false
        local has_lucky = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_glass") then
                    has_glass = true
                elseif SMODS.has_enhancement(v, "m_lucky") then
                    has_lucky = true
                end
            end
        end
        return has_glass and has_lucky
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
        local lucky = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_lucky") then
                table.insert(lucky, v)
            end
        end
        lucky = pseudorandom_element(lucky, pseudoseed('rmagician'))
        local glass = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_glass") then
                table.insert(glass, v)
            end
        end
        for i = 1, #glass do
            local percent = 1.15 - (i - 0.999) / (#glass - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    glass[i]:flip(); play_sound('card1', percent); glass[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #glass do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(lucky, glass[i])
                    return true
                end
            }))
        end
        for i = 1, #glass do
            local percent = 0.85 + (i - 0.999) / (#glass - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    glass[i]:flip(); play_sound('tarot2', percent, 0.6); glass[i]:juice_up(0.3, 0.3); return true
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
    use = function(self, card, area, copier)
        if pseudorandom('rhigh_priestess') < G.GAME.probabilities.normal / card.ability.chance then
            add_tag(Tag("tag_meteor"))
        else
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function() --"borrowed" from Wheel Of Fortune
                    attention_text({
                        text = localize("k_nope_ex"),
                        scale = 1.3,
                        hold = 1.4,
                        major = card,
                        backdrop_colour = G.C.SECONDARY_SET.Tarot,
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
    end,
    bulk_use = defaultBulkUse,
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
    use = function(self, card, area, copier)
        if pseudorandom('remperor') < G.GAME.probabilities.normal / card.ability.chance then
            add_tag(Tag("tag_charm"))
        else
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function() --"borrowed" from Wheel Of Fortune
                    attention_text({
                        text = localize("k_nope_ex"),
                        scale = 1.3,
                        hold = 1.4,
                        major = card,
                        backdrop_colour = G.C.SECONDARY_SET.Tarot,
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
    end,
    bulk_use = defaultBulkUse,
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
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_steel)
        table.insert(info_queue, G.P_CENTERS.m_gold)
    end,
    can_use = function(self, card)
        local has_gold = false
        local has_steel = false
        if G.hand and G.hand.cards then
            for k, v in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(v, "m_gold") then
                    has_gold = true
                elseif SMODS.has_enhancement(v, "m_steel") then
                    has_steel = true
                end
            end
        end
        return has_gold and has_steel
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
        local steel = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_steel") then
                table.insert(steel, v)
            end
        end
        steel = pseudorandom_element(steel, pseudoseed('rchariot'))
        local gold = {}
        for k, v in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(v, "m_gold") then
                table.insert(gold, v)
            end
        end
        for i = 1, #gold do
            local percent = 1.15 - (i - 0.999) / (#gold - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    gold[i]:flip(); play_sound('card1', percent); gold[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #gold do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    copy_card(steel, gold[i])
                    return true
                end
            }))
        end
        for i = 1, #gold do
            local percent = 0.85 + (i - 0.999) / (#gold - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    gold[i]:flip(); play_sound('tarot2', percent, 0.6); gold[i]:juice_up(0.3, 0.3); return true
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
    can_use = function(self, card)
        return true
    end,
    can_bulk_use = true,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                card:juice_up(0.3, 0.5)
                ease_dollars(G.GAME.last_cash_out or G.GAME.starting_params.dollars, true)
                return true
            end
        }))
        delay(0.6)
    end,
    bulk_use = function(self, card, area, copier, number)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                card:juice_up(0.3, 0.5)
                ease_dollars((G.GAME.last_cash_out or G.GAME.starting_params.dollars) * number, true)
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
    use = function(self, card, area, copier)
        if pseudorandom('rwheel_of_fortune') < G.GAME.probabilities.normal / card.ability.chance then
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
        local rank = {}
        for k, v in ipairs(G.playing_cards) do
            if not SMODS.has_no_rank(v) then
                table.insert(rank, v.base.value)
            end
        end
        rank = pseudorandom_element(rank, pseudoseed('rStrength'))
        delay(0.2)
        for k, v in ipairs(G.hand.highlighted) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    SMODS.change_base(v, nil, rank)
                    return true
                end
            }))
        end
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
    key = "rhanged_man",
    set = "Tarot",
    pos = { x = 1, y = 2 },
    atlas = "rtarots",
    can_use = function(self, card)
        return #G.hand.cards > 0
    end,
    use = function(self, card, area, copier)
        local destroy = {}
        if pseudorandom('rhanged_man') < 0.5 then
            for k, v in ipairs(G.hand.highlighted) do
                table.insert(destroy, v)
            end
        else
            for k, v in ipairs(G.hand.cards) do
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
            G.GAME.dollars - rightmost:get_chip_bonus() -
            ((card.area == G.shop_jokers or card.area == G.shop_booster or card.area == G.shop_vouchers) and card.cost or 0) >=
            SMODS.Mods.Talisman and SMODS.Mods.Talisman.can_load and to_big(G.GAME.bankrupt_at) or G.GAME.bankrupt_at
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
    config = { cost = 2, increase = 1.5 },
    loc_vars = function(self, info_queue, card)
        local total = 0
        if G.jokers and G.jokers.cards then
            for k, v in ipairs(G.jokers.cards) do
                total = total + v.sell_cost
            end
        end
        return { vars = { card.ability.cost, card.ability.cost * total, card.ability.increase } }
    end,
    can_use = function(self, card)
        local total = 0
        for k, v in ipairs(G.jokers.cards) do
            total = total + v.sell_cost
        end
        return #G.jokers.cards > 0 and
            G.GAME.dollars - card.ability.cost * total -
            ((card.area == G.shop_jokers or card.area == G.shop_booster or card.area == G.shop_vouchers) and card.cost or 0) >=
            G.GAME.bankrupt_at
    end,
    use = function(self, card, area, copier)
        local total = 0
        for k, v in ipairs(G.jokers.cards) do
            total = total + v.sell_cost
            v.ability.extra_value = (v.ability.extra_value or 0) + v.sell_cost * (card.ability.increase - 1)
            v:set_cost()
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                card:juice_up(0.3, 0.5)
                ease_dollars(-(card.ability.cost * total), true)
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
    use = function(self, card, area, copier)
        if pseudorandom('rjudgement') < G.GAME.probabilities.normal / card.ability.chance then
            add_tag(Tag("tag_buffoon"))
        else
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function() --"borrowed" from Wheel Of Fortune
                    attention_text({
                        text = localize("k_nope_ex"),
                        scale = 1.3,
                        hold = 1.4,
                        major = card,
                        backdrop_colour = G.C.SECONDARY_SET.Tarot,
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
    end,
    bulk_use = defaultBulkUse,
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

table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 8, { id = "c_yart_rmagician" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 9, { id = "c_yart_rempress" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 10, { id = "c_yart_rmoon" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 11, { id = "c_yart_rheirophant" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 12, { id = "c_yart_rworld" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 13, { id = "c_yart_rchariot" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 14, { id = "c_yart_rdevil" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 15, { id = "c_yart_rstar" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 16, { id = "c_yart_rtower" })
table.insert(SMODS.Challenges.c_fragile_1.restrictions.banned_cards, 17, { id = "c_yart_rlovers" })
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
