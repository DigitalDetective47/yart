SMODS.Consumable {
    key = "rfool",
    set = "Tarot",
    pos = { x = 0, y = 0 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        if G.GAME.yart_last_other then
            table.insert(info_queue, G.P_CENTERS[G.GAME.yart_last_other])
        end
        return {
            main_end = { {
                n = G.UIT.C,
                config = { align = "bm", padding = 0.02 },
                nodes = { {
                    n = G.UIT.C,
                    config = { align = "m", colour = G.GAME.yart_last_other and G.C.GREEN or G.C.RED, r = 0.05, padding = 0.05 },
                    nodes = { {
                        n = G.UIT.T,
                        config = {
                            text = " " .. localize(G.GAME.yart_last_other and {
                                type = "name_text",
                                key = G.GAME.yart_last_other,
                                set = G.P_CENTERS[G.GAME.yart_last_other].set
                            } or "k_none") .. " ",
                            colour = G.C.UI.TEXT_LIGHT,
                            scale = 0.3,
                            shadow = true
                        }
                    } }
                } }
            } }
        }
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables)
            and G.GAME.yart_last_other
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("timpani")
            SMODS.add_card { key = G.GAME.yart_last_other }
            card:juice_up(0.3, 0.5)
            return true
        end })
        delay(0.6)
    end,
}

SMODS.Consumable {
    key = "rmagician",
    set = "Tarot",
    pos = { x = 1, y = 0 },
    atlas = "rtarots",
    config = { chance = 7 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_lucky)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = StrangeLib.consumable.use_templates.hand_not_empty,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "rmagician", 1, card.ability.chance) then
            StrangeLib.consumable.tarot_animation(G.hand.cards, function(target)
                target:set_ability(G.P_CENTERS.m_lucky)
            end)
        else
            StrangeLib.consumable.nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
}

SMODS.Consumable {
    key = "rhigh_priestess",
    set = "Tarot",
    pos = { x = 2, y = 0 },
    atlas = "rtarots",
    config = { chance = 2 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_TAGS.tag_meteor)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = StrangeLib.consumable.use_templates.always_usable,
    can_bulk_use = true,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "rhigh_priestess", 1, card.ability.chance) then
            add_tag(Tag("tag_meteor"))
        else
            StrangeLib.consumable.nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
}

SMODS.Consumable {
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
        StrangeLib.consumable.tarot_animation(G.hand.highlighted, function(target)
            target:set_ability(G.P_CENTERS.m_mult)
        end)
    end,
}

SMODS.Consumable {
    key = "remperor",
    set = "Tarot",
    pos = { x = 4, y = 0 },
    atlas = "rtarots",
    config = { chance = 2 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_TAGS.tag_charm)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = StrangeLib.consumable.use_templates.always_usable,
    can_bulk_use = true,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "remperor", 1, card.ability.chance) then
            add_tag(Tag("tag_charm"))
        else
            StrangeLib.consumable.nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
}

SMODS.Consumable {
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
        StrangeLib.consumable.tarot_animation(targets, function(target)
            target:set_ability(G.P_CENTERS.m_bonus)
        end)
    end,
}

SMODS.Consumable {
    key = "rlovers",
    set = "Tarot",
    pos = { x = 1, y = 1 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_wild)
    end,
    can_use = StrangeLib.consumable.use_templates.hand_not_empty,
    use = function(self, card, area)
        G.hand:unhighlight_all()
        ---@type Card
        local primary_target = pseudorandom_element(G.hand.cards, pseudoseed("rlovers"))
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
        StrangeLib.consumable.tarot_animation(targets, function(target)
            target:set_ability(G.P_CENTERS.m_wild)
        end)
    end,
}

SMODS.Consumable {
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
            ---@type Card[]
            local valid_targets = SMODS.shallow_copy(G.hand.cards)
            for _ = 1, G.hand.config.card_limit - card.ability.extra do
                ---@type Card, integer
                local new_target, i = pseudorandom_element(valid_targets, pseudoseed("rchariot"))
                table.insert(modification_list, new_target)
                table.remove(valid_targets, i)
            end
            table.sort(modification_list, StrangeLib.ltr)
        end
        StrangeLib.consumable.tarot_animation(modification_list, function(target)
            target:set_ability(G.P_CENTERS.m_steel)
        end)
    end,
}

SMODS.Consumable {
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
            ---@type Card[]
            local valid_targets = SMODS.shallow_copy(G.hand.cards)
            for _ = 1, modification_count do
                ---@type Card, integer
                local new_target, i = pseudorandom_element(valid_targets, pseudoseed("rchariot"))
                table.insert(modification_list, new_target)
                table.remove(valid_targets, i)
            end
            table.sort(modification_list, StrangeLib.ltr)
        end
        StrangeLib.consumable.tarot_animation(modification_list, function(target)
            target:set_ability(G.P_CENTERS.m_glass)
        end)
    end,
}

SMODS.Consumable {
    key = "rhermit",
    set = "Tarot",
    pos = { x = 4, y = 1 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.last_cash_out or 0 } }
    end,
    in_pool = function(self, args)
        return G.GAME.last_cash_out ~= nil
    end,
    can_use = function(self, card)
        return G.GAME.last_cash_out ~= nil
    end,
    can_bulk_use = true,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("timpani")
            card:juice_up(0.3, 0.5)
            ease_dollars(G.GAME.last_cash_out, true)
            return true
        end })
        delay(0.6)
    end,
    bulk_use = function(self, card, area, number)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("timpani")
            card:juice_up(0.3, 0.5)
            ease_dollars(G.GAME.last_cash_out * number, true)
            return true
        end })
        delay(0.6)
    end,
}

SMODS.Consumable {
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
        for _, joker in pairs(G.jokers.cards) do
            if joker.ability.set == "Joker" and (not joker.edition) and not (SMODS.is_eternal(joker, card)) then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        ---@type Card[]
        local pool = {}
        for _, joker in pairs(G.jokers.cards) do
            if joker.ability.set == "Joker" and (not joker.edition) and not (SMODS.is_eternal(joker, card)) then
                table.insert(pool, joker)
            end
        end
        ---@type Card
        local target = pseudorandom_element(pool, pseudoseed("rwheel_of_fortune"))
        if SMODS.pseudorandom_probability(card, "rwheel_of_fortune", 1, card.ability.chance) then
            G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
                target:set_edition("e_negative")
                card:juice_up(0.3, 0.5)
                return true
            end })
        else
            G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
                SMODS.destroy_cards(target)
                card:juice_up(0.3, 0.5)
                return true
            end })
        end
    end,
}

SMODS.Consumable {
    key = "rstrength",
    set = "Tarot",
    pos = { x = 0, y = 2 },
    atlas = "rtarots",
    config = { min_highlighted = 1, max_highlighted = 3 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.max_highlighted } }
    end,
    can_use = StrangeLib.consumable.use_templates.selection_limit,
    use = function(self, card, area)
        ---@type string[]
        local ranks = {}
        for _, other in ipairs(G.playing_cards) do
            if not SMODS.has_no_rank(other) then
                table.insert(ranks, other.base.value)
            end
        end
        ---@type string
        local rank = pseudorandom_element(ranks, pseudoseed("rstrength"))
        StrangeLib.consumable.tarot_animation(G.hand.highlighted, function(target)
            local ret, message = SMODS.change_base(target, nil, rank)
            if not ret then
                sendErrorMessage(message)
            end
        end)
    end,
}

SMODS.Consumable {
    key = "rhanged_man",
    set = "Tarot",
    pos = { x = 1, y = 2 },
    atlas = "rtarots",
    can_use = StrangeLib.consumable.use_templates.hand_not_empty,
    use = function(self, card, area)
        ---@type Card[]
        local destroy
        if SMODS.pseudorandom_probability(card, "rhanged_man", 1, 2, nil, true) then
            destroy = G.hand.highlighted
        else
            ---@type table<Card, true>
            local highlighted = StrangeLib.as_set(G.hand.highlighted)
            destroy = {}
            for _, hand_card in ipairs(G.hand.cards) do
                if not highlighted[hand_card] then
                    table.insert(destroy, hand_card)
                end
            end
        end
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("tarot1")
            card:juice_up(0.3, 0.5)
            return true
        end })
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.2, func = function()
            SMODS.destroy_cards(destroy)
            G.hand:unhighlight_all()
            return true
        end })
    end,
}

SMODS.Consumable {
    key = "rdeath",
    set = "Tarot",
    pos = { x = 2, y = 2 },
    atlas = "rtarots",
    config = { min_highlighted = 2, max_highlighted = 2 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.max_highlighted } }
    end,
    can_use = StrangeLib.consumable.use_templates.selection_limit,
    use = function(self, card, area)
        ---@type Card
        local left = G.hand.highlighted[1]
        ---@type Card
        local right = G.hand.highlighted[2]
        if left.T.x > right.T.x then
            left, right = right, left
        end
        StrangeLib.consumable.tarot_animation(G.hand.highlighted, function(target)
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
}

SMODS.Consumable {
    key = "rtemperance",
    set = "Tarot",
    pos = { x = 3, y = 2 },
    atlas = "rtarots",
    config = { extra = 25, factor = 1 },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.consumeable_usage_total and math.min(G.GAME.consumeable_usage_total.all * card.ability.factor, card.ability.extra) or 0, card.ability.factor, card.ability.extra } }
    end,
    can_use = StrangeLib.consumable.use_templates.always_usable,
    can_bulk_use = true,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("timpani")
            card:juice_up(0.3, 0.5)
            ease_dollars(math.min((G.GAME.consumeable_usage_total.all - 1) * card.ability.factor, card.ability.extra),
                true)
            return true
        end })
        delay(0.6)
    end,
    bulk_use = function(self, card, area, number)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("timpani")
            card:juice_up(0.3, 0.5)
            ease_dollars(
                math.min((G.GAME.consumeable_usage_total.all - 1) * card.ability.factor, card.ability.extra) * number,
                true)
            return true
        end })
        delay(0.6)
    end,
}

SMODS.Consumable {
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
        local hand_set = StrangeLib.as_set(G.hand.cards)
        ---@type Card[]
        local modification_list = {}
        ---@type Card[]
        local remaining_cards = SMODS.shallow_copy(G.playing_cards)
        for _ = 1, math.min(math.floor(G.GAME.dollars / card.ability.money) * card.ability.cards, card.ability.limit) do
            if next(remaining_cards) then
                local target = table.remove(remaining_cards, pseudorandom("rdevil", 1, #remaining_cards))
                if hand_set[target] then
                    table.insert(modification_list, target)
                else
                    target:set_ability(G.P_CENTERS.m_gold)
                end
            else
                pseudoseed("rdevil")
            end
        end
        table.sort(modification_list, StrangeLib.ltr)
        StrangeLib.consumable.tarot_animation(modification_list, function(target)
            target:set_ability(G.P_CENTERS.m_gold)
        end)
    end,
}

SMODS.Consumable {
    key = "rtower",
    set = "Tarot",
    pos = { x = 0, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_stone)
    end,
    can_use = function(self, card)
        for _, other in ipairs(G.hand.cards) do
            if next(SMODS.get_enhancements(other)) then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        ---@type Card[]
        local modification_list = {}
        for _, other in ipairs(G.hand.cards) do
            if next(SMODS.get_enhancements(other)) then
                table.insert(modification_list, other)
            end
        end
        StrangeLib.consumable.tarot_animation(modification_list, function(target)
            target:set_ability(G.P_CENTERS.m_stone)
        end)
    end,
}

SMODS.Consumable {
    key = "rstar",
    set = "Tarot",
    pos = { x = 1, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_gold)
    end,
    can_use = function(self, card)
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Diamonds") then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("tarot1")
            card:juice_up(0.3, 0.5)
            return true
        end })
        ---@type Card[]
        local diamonds = {}
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Diamonds") then
                table.insert(diamonds, other)
            end
        end
        StrangeLib.consumable.tarot_animation(diamonds, function(target)
            target:set_ability(G.P_CENTERS.m_gold)
        end)
    end,
}

SMODS.Consumable {
    key = "rmoon",
    set = "Tarot",
    pos = { x = 2, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_mult)
    end,
    can_use = function(self, card)
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Clubs") then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("tarot1")
            card:juice_up(0.3, 0.5)
            return true
        end })
        ---@type Card[]
        local clubs = {}
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Clubs") then
                table.insert(clubs, other)
            end
        end
        StrangeLib.consumable.tarot_animation(clubs, function(target)
            target:set_ability(G.P_CENTERS.m_mult)
        end)
    end,
}

SMODS.Consumable {
    key = "rsun",
    set = "Tarot",
    pos = G.localization.descriptions.Tarot.c_sun.name == "The Sus" and { x = 5, y = 2 } or { x = 3, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_glass)
    end,
    can_use = function(self, card)
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Hearts") then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("tarot1")
            card:juice_up(0.3, 0.5)
            return true
        end })
        ---@type Card[]
        local hearts = {}
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Hearts") then
                table.insert(hearts, other)
            end
        end
        StrangeLib.consumable.tarot_animation(hearts, function(target)
            target:set_ability(G.P_CENTERS.m_glass)
        end)
    end,
}

SMODS.Consumable {
    key = "rjudgement",
    set = "Tarot",
    pos = { x = 4, y = 3 },
    atlas = "rtarots",
    config = { chance = 3 },
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_TAGS.tag_buffoon)
        return { vars = { G.GAME.probabilities.normal, card.ability.chance } }
    end,
    can_use = StrangeLib.consumable.use_templates.always_usable,
    can_bulk_use = true,
    use = function(self, card, area)
        if SMODS.pseudorandom_probability(card, "rjudgement", 1, card.ability.chance) then
            add_tag(Tag("tag_buffoon"))
        else
            StrangeLib.consumable.nope(card, G.C.SECONDARY_SET.Tarot)
        end
    end,
}

SMODS.Consumable {
    key = "rworld",
    set = "Tarot",
    pos = { x = 5, y = 3 },
    atlas = "rtarots",
    loc_vars = function(self, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_bonus)
    end,
    can_use = function(self, card)
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Spades") then
                return true
            end
        end
        return false
    end,
    use = function(self, card, area)
        G.E_MANAGER:add_event(Event { trigger = "after", delay = 0.4, func = function()
            play_sound("tarot1")
            card:juice_up(0.3, 0.5)
            return true
        end })
        ---@type Card[]
        local spades = {}
        for _, other in ipairs(G.hand.cards) do
            if other:is_suit("Spades") then
                table.insert(spades, other)
            end
        end
        StrangeLib.consumable.tarot_animation(spades, function(target)
            target:set_ability(G.P_CENTERS.m_bonus)
        end)
    end,
}
