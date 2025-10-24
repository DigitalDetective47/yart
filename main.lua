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

local cash_out_hook = G.FUNCS.cash_out
function G.FUNCS.cash_out(e)
    G.GAME.yart_last_round_score = G.GAME.chips
    G.GAME.last_cash_out = G.GAME.current_round.dollars
    cash_out_hook(e)
end

SMODS.load_file("tarot.lua")()

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
