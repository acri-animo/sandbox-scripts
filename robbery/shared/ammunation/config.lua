_ammuDoors = {
    {
        coords = vector3(811.547, -2148.196, 29.623),
        heading = 189.473,
        door = "ammunation1_front_left",
        requiredDoors = {},
    },
    {
        coords = vector3(810.993, -2181.674, 27.545),
        heading = 272.981,
        door = "ammunation1_lockerroom",
        requiredDoors = {
            "ammunation1_front_left",
            "ammunation1_backentrance",
        },
    },
    {
        coords = vector3(809.150, -2183.522, 27.545),
        heading = 183.626,
        door = "ammunation1_mainloot",
        requiredDoors = {
            "ammunation1_front_left",
            "ammunation1_backentrance",
        },
    },
}

_ammuOfficeDoors = {
    {
        coords = vector3(820.312, -2171.391, 33.074),
        heading = 273.487,
        door = "ammunation1_office",
        requiredDoors = {"ammunation1_mainloot"},
    },
    {
        coords = vector3(826.917, -2163.866, 33.074),
        heading = 176.458,
        door = "ammunation1_office2",
        requiredDoors = {"ammunation1_mainloot"},
    },
}

_ammuCardDoor = {
    coords = vector3(810.604, -2175.076, 27.545),
    heading = 183.702,
    door = "ammunation1_backentrance",
    requiredDoors = {
        "ammunation1_front_left",
    },
}

_ammuDrillPoints = {
    {
        coords = vector3(814.87, -2177.86, 27.55),
        length = 1.2,
        width = 0.2,
        options = {
            heading = 0,
            --debugPoly = true,
            minZ = 26.55,
            maxZ = 28.55,
        },
        data = {
            wallId = 1,
        },
    },
    {
        coords = vector3(814.88, -2181.69, 27.55),
        length = 1.2,
        width = 0.2,
        options = {
            heading = 0,
            --debugPoly = true,
            minZ = 26.55,
            maxZ = 28.55,
        },
        data = {
            wallId = 2,
        },
    },
}

_ammuPedSpawns = {
    { coords = vector4(824.103, -2158.981, 27.917, 43.125) },
    { coords = vector4(824.033, -2153.968, 27.917, 70.154) },
    { coords = vector4(822.836, -2149.852, 27.931, 91.330) },
    { coords = vector4(818.344, -2157.573, 27.931, 51.086) },
    { coords = vector4(826.429, -2162.482, 27.230, 36.877) },
    { coords = vector4(818.632, -2162.690, 27.229, 65.244) },
    { coords = vector4(811.844, -2163.325, 27.227, 357.922) },
    { coords = vector4(816.851, -2150.197, 27.917, 82.669) },
    { coords = vector4(813.901, -2161.156, 32.074, 358.731) },
    { coords = vector4(810.221, -2160.993, 32.074, 355.612) },
    { coords = vector4(825.009, -2161.078, 32.074, 36.073) },
    { coords = vector4(825.987, -2160.877, 32.074, 47.347) },
    { coords = vector4(820.223, -2154.028, 27.917, 68.644) },
}

_ammuMainLoot = {
    {
        coords = vector3(809.41, -2190.77, 27.55),
        length = 0.8,
        width = 1.8,
        options = {
            heading = 0,
            --debugPoly = true,
            minZ = 26.55,
            maxZ = 28.75,
        },
        data = {
            lootId = 1,
        },
    },
    {
        coords = vector3(811.48, -2190.79, 27.55),
        length = 0.65,
        width = 1.2,
        options = {
            heading = 1,
            --debugPoly = true,
            minZ = 26.55,
            maxZ = 28.75,
        },
        data = {
            lootId = 2,
        },
    },
    {
        coords = vector3(812.57, -2184.78, 27.55),
        length = 0.6,
        width = 3.0,
        options = {
            heading = 0,
            --debugPoly = true,
            minZ = 26.55,
            maxZ = 29.15,
        },
        data = {
            lootId = 3,
        },
    },
    {
        coords = vector3(811.5, -2187.53, 27.55),
        length = 1.0,
        width = 2.2,
        options = {
            heading = 0,
            --debugPoly = true,
            minZ = 26.55,
            maxZ = 29.15,
        },
        data = {
            lootId = 4,
        },
    },
}