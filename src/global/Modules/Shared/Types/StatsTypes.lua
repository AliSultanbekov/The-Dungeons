
export type CapConfig = {
    LevelSeg: number,
    HardCap: number,
    SoftCap: number,
    BStart: number,
    BEnd: number,
}

export type StatConfig = {
    CRITICAL_RATING: CapConfig,

    PHYSICAL_MITIGATION: CapConfig,
    TACTICAL_MITIGATION: CapConfig,

    CRITICAL_DEFENSE: CapConfig,

    MANA_REGEN: CapConfig,
    HEALTH_REGEN: CapConfig,

    OUTGOING_HEALING: CapConfig,
    INCOMING_HEALING: CapConfig,

    TACTICAL_MASTERY: CapConfig,
    PHYSICAL_MASTERY: CapConfig,
}

export type RawStats = {
    Health : number,
    MaxHealth : number,
    HealthBubble : number,
    Mana : number,
    CriticalRating : number,
    PhysicalMitigation : number,
    TacticalMitigation : number,
    CriticalDefense : number,
    ManaRegen : number,
    HealthRegen : number,
    OutgoingHealing : number,
    IncomingHealing : number,
    TacticalMastery : number,
    PhysicalMastery : number,
}

export type PrimaryStats = {
    Strength : number,
    Dexterity : number,
    Intelligence : number,
    Vitality : number,
    Focus : number,
}
    
export type PlayerStats = {
    RawStats : RawStats,
    PrimaryStats : PrimaryStats,
}

return {}