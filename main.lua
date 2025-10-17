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

---`can_use` function used by multiple reversed tarot cards
---@param self SMODS.Consumable
---@param card Card
---@return boolean
local function hand_not_empty(self, card)
    return #G.hand.cards ~= 0
end

---`can_use` function for always usable consumables
---@param self SMODS.Consumable
---@param card Card
---@return boolean
local function always_usable(self, card)
    return true
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
    can_use = hand_not_empty,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "rmagician", 1, card.ability.chance) then
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
    can_use = always_usable,
    can_bulk_use = true,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "rhigh_priestess", 1, card.ability.chance) then
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
    config = { extra = 1 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_mult)
        return { vars = { card.ability.extra } }
    end,
    can_use = function(self, card)
        ---@type integer
        local highlighted_count = #G.hand.highlighted * card.ability.extra
        if highlighted_count < 1 then
            return false
        end
        for _, other in ipairs(G.hand.cards) do
            if SMODS.has_enhancement(other, "m_mult") then
                highlighted_count = highlighted_count - 1
            end
        end
        return highlighted_count <= 0
    end,
    use = function(self, card, area)
        modify_cards(G.hand.highlighted, function(target)
            target:set_ability(G.P_CENTERS.m_mult)
        end)
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
    can_use = always_usable,
    can_bulk_use = true,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "remperor", 1, card.ability.chance) then
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
    config = { threshold = 5 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_bonus)
        return { vars = { card.ability.threshold } }
    end,
    can_use = function(self, card)
        for _, other in ipairs(G.hand.cards) do
            if StrangeLib.safe_compare(other:get_chip_bonus(), "<=", card.ability.threshold) then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        ---@type Card[]
        local targets = {}
        for _, other in ipairs(G.hand.cards) do
            if StrangeLib.safe_compare(other:get_chip_bonus(), "<=", card.ability.threshold) then
                table.insert(targets, other)
            end
        end
        modify_cards(targets, function(target)
            target:set_ability(G.P_CENTERS.m_bonus)
        end)
    end,
})
SMODS.Consumable({
    key = "rlovers",
    set = "Tarot",
    pos = { x = 1, y = 1 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_wild)
    end,
    can_use = hand_not_empty,
    use = function(self, card, area)
        G.hand:unhighlight_all()
        ---@type Card
        local primary_target = pseudorandom_element(G.hand.cards, pseudoseed("rlovers")) --[[@as Card]]
        G.hand:add_to_highlighted(primary_target, true)
        ---@type Card[]
        local targets = { primary_target }
        if SMODS.has_any_suit(primary_target) then
            for _, hand_card in ipairs(G.hand.cards) do
                if hand_card ~= primary_target and not SMODS.has_no_suit(hand_card) then
                    table.insert(targets, hand_card)
                end
            end
        elseif not SMODS.has_no_suit(primary_target) then
            ---@type { [string]: true }
            local targeted_suits = {}
            for suit, _ in pairs(SMODS.Suits) do
                if primary_target:is_suit(suit) then
                    targeted_suits[suit] = true
                end
            end
            for _, hand_card in ipairs(G.hand.cards) do
                if hand_card ~= primary_target then
                    for suit, _ in pairs(targeted_suits) do
                        if hand_card:is_suit(suit) then
                            table.insert(targets, hand_card)
                            break
                        end
                    end
                end
            end
        end
        delay(0.5)
        modify_cards(targets, function(target)
            target:set_ability(G.P_CENTERS.m_wild)
        end)
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
            local valid_targets = SMODS.shallow_copy(G.hand.cards)
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
local cash_out_hook = G.FUNCS.cash_out
function G.FUNCS.cash_out(e)
    G.GAME.yart_last_round_score = G.GAME.chips
    cash_out_hook(e)
end

SMODS.Consumable({
    key = "rjustice",
    set = "Tarot",
    pos = { x = 3, y = 1 },
    atlas = "rtarots",
    config = { base = 100 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_glass)
        G.GAME.yart_last_round_score = G.GAME.yart_last_round_score or 1
        return { vars = { card.ability.base, math.floor(card.ability.base == 100 and math.log10(G.GAME.yart_last_round_score) / 2 or math.log(G.GAME.yart_last_round_score, card.ability.base)) } }
    end,
    can_use = function(self, card)
        return #G.hand.cards > 0 and StrangeLib.safe_compare(G.GAME.yart_last_round_score, ">=", card.ability.base)
    end,
    use = function(self, card, area)
        ---@type integer
        local modification_count = math.floor(card.ability.base == 100 and math.log10(G.GAME.yart_last_round_score) / 2 or
            math.log(G.GAME.yart_last_round_score, card.ability.base))
        ---@type Card[]
        local modification_list
        if StrangeLib.safe_compare(#G.hand.cards, "<", modification_count) then
            modification_list = G.hand.cards
            for _ = 1, #G.hand.cards do
                pseudoseed("rjustice")
            end
        else
            modification_list = {}
            ---@type table<Card, true>
            local targets = {}
            ---@type Card[]
            local valid_targets = SMODS.shallow_copy(G.hand.cards)
            for _ = 1, modification_count do
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
            target:set_ability(G.P_CENTERS.m_glass)
        end)
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
        if SMODS.pseudorandom_probability(card, 'rwheel_of_fortune', 1, card.ability.chance) then
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
        return next(G.hand.highlighted) and #G.hand.highlighted <= card.ability.limit
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
        local rank = pseudorandom_element(ranks, pseudoseed('rstrength')) --[[@as string]]
        delay(0.2)
        modify_cards(G.hand.highlighted, function(target)
            local ret, message = SMODS.change_base(target, nil, rank)
            if not ret then
                sendErrorMessage(message)
            end
        end)
    end,
})
SMODS.Consumable({
    key = "rhanged_man",
    set = "Tarot",
    pos = { x = 1, y = 2 },
    atlas = "rtarots",
    can_use = hand_not_empty,
    use = function(self, card, area)
        ---@type Card[]
        local destroy
        if SMODS.pseudorandom_probability(card, "rhanged_man", 1, 2, nil, true) then
            destroy = G.hand.highlighted
        else
            destroy = SMODS.shallow_copy(G.hand.cards)
            for k, v in ipairs(G.hand.highlighted) do
                for dk, dv in ipairs(destroy) do
                    if v == dv then
                        table.remove(destroy, dk)
                        break
                    end
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
                SMODS.destroy_cards(destroy)
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
    config = { limit = 2 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.limit } }
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == card.ability.limit
    end,
    use = function(self, card, area)
        ---@type Card
        local left = G.hand.highlighted[1]
        ---@type Card
        local right = G.hand.highlighted[1]
        for _, other in ipairs(G.hand.highlighted) do
            if other.T.x < left.T.x then
                left = other
            end
            if other.T.x > right.T.x then
                right = other
            end
        end
        modify_cards(G.hand.highlighted, function(target)
            local ret, message = SMODS.change_base(target, left.base.suit, left.base.value)
            if not ret then
                sendErrorMessage(message)
                return
            end
            target:set_ability(right.config.center)
            target:set_seal(right.seal, true, true)
            target:set_edition(right.edition, true, true)
        end)
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
    can_use = always_usable,
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
    config = { money = 10, cards = 1, limit = 5 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_gold)
        return { vars = { card.ability.money, card.ability.cards, card.ability.limit, math.min(math.floor(G.GAME.dollars / card.ability.money) * card.ability.cards, card.ability.limit) } }
    end,
    can_use = function(self, card)
        return StrangeLib.safe_compare(G.GAME.dollars, ">", card.ability.money)
    end,
    use = function(self, card, area)
        ---@type table<Card, true>
        local targets = {}
        ---@type Card[]
        local remaining_cards = SMODS.shallow_copy(G.playing_cards)
        for _ = 1, math.min(math.floor(G.GAME.dollars / card.ability.money) * card.ability.cards, card.ability.limit) do
            targets[table.remove(remaining_cards, pseudorandom('rdevil', 1, #remaining_cards))] = true
        end
        ---@type Card[]
        local modification_list = {}
        for _, other in ipairs(G.hand.cards) do
            if targets[other] then
                table.insert(modification_list, other)
                targets[other] = nil
            end
        end
        for other, _ in pairs(targets) do
            table.insert(modification_list, other)
        end
        modify_cards(modification_list, function(target)
            target:set_ability(G.P_CENTERS.m_gold)
        end)
    end,
})
SMODS.Consumable({
    key = "rtower",
    set = "Tarot",
    pos = { x = 0, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_stone)
    end,
    can_use = function(self, card)
        for _, other in ipairs(G.hand.cards) do
            if next(SMODS.get_enhancements(other) --[[@as table]]) then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        --@type Card[]
        local targets = {}
        for _, other in ipairs(G.hand.cards) do
            if next(SMODS.get_enhancements(other) --[[@as table]]) then
                table.insert(targets, other)
            end
        end
        modify_cards(targets, function(target)
            target:set_ability(G.P_CENTERS.m_stone)
        end)
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
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Diamonds") then
                return true
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
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Clubs") then
                return true
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
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Hearts") then
                return true
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
    can_use = always_usable,
    can_bulk_use = true,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "rjudgement", 1, card.ability.chance) then
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
        for k, v in ipairs(G.hand.cards) do
            if v:is_suit("Spades") then
                return true
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

SMODS.Challenge({
    key = "dinnerbone",
    restrictions = { banned_cards = {} }
})

G.E_MANAGER:add_event(Event({
    func = function()
        for _, center in ipairs(G.P_CENTER_POOLS.Tarot) do
            if center.original_mod ~= SMODS.find_mod("YART")[1] then
                table.insert(SMODS.Challenges.c_yart_dinnerbone.restrictions.banned_cards, { id = center.key })
            end
        end
        return true
    end
}))
