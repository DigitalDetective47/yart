SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
}

SMODS.Atlas {
    key = "rtarots",
    path = "tarot.png",
    px = 71,
    py = 95,
}

SMODS.load_file("tarot.lua")()

SMODS.Challenge {
    key = "dinnerbone",
    restrictions = { banned_cards = {} }
}

G.E_MANAGER:add_event(Event { func = function()
    for _, center in ipairs(G.P_CENTER_POOLS.Tarot) do
        if center.original_mod ~= SMODS.find_mod("YART")[1] then
            table.insert(SMODS.Challenges.c_yart_dinnerbone.restrictions.banned_cards, { id = center.key })
        end
    end
    return true
end })

StrangeLib.load_compat()
StrangeLib.update_challenge_restrictions("challenge_bans.json")

SMODS.current_mod.calculate = function(self, context)
    if context.using_consumeable then
        if context.consumeable.ability.set ~= "Tarot" and context.consumeable.ability.set ~= "Planet" then
            G.GAME.yart_last_other = context.consumeable.config.center_key
        end
    elseif context.starting_shop then
        G.GAME.last_cash_out = G.GAME.current_round.dollars
    elseif context.end_of_round and not context.individual and not context.repetition then
        G.GAME.yart_last_round_score = G.GAME.chips
    end
end
