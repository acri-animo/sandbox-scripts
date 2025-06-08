_cornerSelling = {
    baseDenyChance = 25, -- This is the chance for player to be denied by ped

    -- Bag Amounts
    baseWeed = math.random(1,2), -- # of weed bags player can sell (at rep level 0)
    baseOxy = math.random(1,2), -- # of oxy player can sell (at rep level 0)
    repMultiplier = 0.1, -- This sets the rep multiplier, which allows player to sell more bags at higher rep
    
    -- Money Amounts (meth and coke only give cash, but oxy/weed have a chance to give money rolls)
    chanceForRolls = 55, -- This sets the chance for player to receive money rolls instead of cash if they sell oxy/weed
    baseWeedPayment = 25, -- base Weed cash payment
    baseOxyPayment = 30, -- base Oxy cash payment
    baseMethPayment = 50, -- base Meth cash payment
    baseCokePayment = 100, -- base Coke cash payment
    baseMoonshinePayment = 250, -- base Moonshine payment
    baseWeedRolls = math.random(1,2), -- base Weed money rolls if chance is met
    baseOxyRolls = math.random(1,3), -- base Oxy money rolls if chance is met
    moneyMultiplier = 0.1, -- This sets the rep multiplier to receive more cash or moneyrolls based on rep

    -- Ped Deny Notifications
    denyNotis = {
        "Get out of my face!",
        "I don't want your fucking drugs!",
        "I'm calling the cops!",
        "You make me sick...",
        "You are part of the problem",
        "I should beat your ass",
        "Get a fucking life",
        "I already have a plug",
    },

    pedDenySpeech = {
        "Generic_Fuck_You",
        "GENERIC_CURSE_HIGH",
        "APOLOGY_NO_TROUBLE",
        "GENERIC_INSULT_MED",
        "GENERIC_INSULT_HIGH",
    },
}