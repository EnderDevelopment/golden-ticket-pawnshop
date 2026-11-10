Config = {}

Config.Framework = 'auto' -- auto, qb, esx, standalone
Config.Inventory = 'auto' -- auto, ox, qb, esx
Config.Currency = 'cash'
Config.InteractionDistance = 2.5
Config.MarkerDistance = 18.0
Config.UseBlips = true
Config.Blip = {
    sprite = 431,
    colour = 5,
    scale = 0.72,
    name = 'Pawnshop'
}

Config.Shops = {
    {
        label = 'Downtown Pawn',
        coords = vector3(412.42, 314.18, 103.02),
        blip = true
    }
}

-- Add or remove entries here. The name must match your inventory item name.
Config.Items = {
    { name = 'goldchain', label = 'Gold Chain', category = 'Jewelry', price = 350, icon = '◆', description = 'A heavy chain with a warm golden shine.' },
    { name = 'rolex', label = 'Luxury Watch', category = 'Jewelry', price = 1250, icon = '◷', description = 'A premium timepiece in excellent condition.' },
    { name = 'diamond', label = 'Diamond', category = 'Gems', price = 900, icon = '◇', description = 'A cut stone with serious resale value.' },
    { name = 'goldbar', label = 'Gold Bar', category = 'Valuables', price = 2400, icon = '▰', description = 'Refined gold, stamped and ready to move.' },
    { name = 'markedbills', label = 'Marked Bills', category = 'Cash', price = 80, icon = '$', description = 'Cash with a story best left untold.' },
    { name = 'electronics', label = 'Electronics', category = 'Tech', price = 175, icon = '▣', description = 'Used electronics that still have a market.' }
}
