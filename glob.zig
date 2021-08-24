
pub const Phys = struct{
    pos: Pos,
    model: Model,
};

pub const Pos = struct{
    x: i8,
    y: i8,
};

pub const Model = [][]Limb;

pub const Limb = u8;
pub const LIMB_NOPHYS: Limb = ' ';
pub const LIMB_TRANSPARENT: Limb = ' ';
