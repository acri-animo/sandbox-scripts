trucking = {
    jobs = {
        legal = {
            [0] = {
                truck = "phantom",
                trailer = "trailers",
                taskOne = "Deliver materials to construction site",
                dropString = "Deliver materials",
                dropProg = "Unloading materials...",
                dropPed = "s_m_y_construct_02",
                itemRewards = {
                    {35, "plastic", math.random(5,8)},
                    {35, "rubber", math.random(5,8)},
                    {35, "scrapmetal", math.random(5,8)},
                    {35, "electronic_parts", math.random(5,8)},
                    {35, "copperwire", math.random(5,8)},
                    {35, "glue", math.random(5,8)},
                    {35, "ironbar", math.random(5,8)},
                    {35, "heavy_glue", math.random(5,8)},
                },
                dropoffLocations = {
                    vector4(-145.455, -1026.651, 26.286, 74.028),
                    vector4(-440.820, -990.102, 22.906, 92.155),
                    vector4(52.066, -416.565, 38.922, 261.532),
                    vector4(1208.747, 1855.197, 77.912, 41.141)
                },
            },
            [2] = {
                truck = "phantom",
                trailer = "trailers2",
                taskOne = "Deliver meat to the butcher",
                dropString = "Deliver meat",
                dropProg = "Unloading shmeat...",
                dropPed = "s_m_y_chef_01",
                itemRewards = {
                    {60, "chicken", math.random(3,6)},
                    {60, "beef", math.random(3,6)},
                    {60, "pork", math.random(3,6)},
                    {60, "venison", math.random(3,6)},
                },
                dropoffLocations = {
                    vector4(-66.957, 6270.949, 30.330, 37.123)
                },
            },
            [4] = {
                truck = "phantom",
                trailer = "trailers2",
                taskOne = "Deliver alcohol",
                dropString = "Deliver alcohol",
                dropProg = "Unloading alcohol...",
                dropPed = "u_f_y_lauren",
                itemRewards = {
                    {60, "beer", math.random(3,6)},
                    {60, "whiskey", math.random(3,6)},
                    {60, "rum", math.random(3,6)},
                    {60, "wine_bottle", math.random(3,6)},
                    {60, "vodka", math.random(3,6)},
                    {60, "tequila", math.random(3,6)},
                },
                dropoffLocations = {
                    vector4(-1925.525, 2048.098, 139.832, 260.689),
                    vector4(-1432.211, -647.882, 27.673, 214.883),
                    vector4(1407.663, 3619.119, 33.894, 294.572)
                },
            },
            [6] = {
                truck = "phantom",
                trailer = "trailers3",
                taskOne = "Deliver fertilizer",
                dropString = "Deliver fertilizer",
                dropProg = "Unloading fertilizer...",
                dropPed = "a_m_m_farmer_01",
                itemRewards = {
                    {45, "fertilizer_nitrogen", math.random(3,5)},
                    {45, "fertilizer_phosphorus", math.random(3,5)},
                    {45, "fertilizer_potassium", math.random(3,5)},
                    {45, "apples", math.random(5,7)},
                    {45, "grapes", math.random(5,7)},
                    {45, "blueberries", math.random(5,7)},
                    {20, "weed_bud", math.random(2,4)},
                },
                dropoffLocations = {
                    vector4(2416.009, 4993.580, 45.227, 135.751),
                    vector4(1930.039, 4634.855, 39.472, 3.923),
                    vector4(408.164, 6498.113, 26.743, 173.971)
                },
            },
            [8] = {
                truck = "phantom",
                trailer = "trailers3",
                taskOne = "Deliver medical supplies",
                dropString = "Deliver medical supplies",
                dropProg = "Unloading medical supplies...",
                dropPed = "s_m_m_doctor_01",
                itemRewards = {
                    {100, "bandage", math.random(25,30)},
                },
                dropoffLocations = {
                    vector4(-282.596, 6324.471, 31.331, 226.558),
                },
            },
            [10] = {
                truck = "phantom",
                trailer = "tanker",
                taskOne = "Deliver fuel (CAUTION! Too much damage will cause an explosion!)",
                dropString = "Deliver fuel",
                dropProg = "Unloading fuel...",
                dropPed = "s_m_m_cntrybar_01",
                cashReward = 5000,
                dropoffLocations = {
                    vector4(634.951, 259.774, 102.090, 115.871),
                    vector4(-2063.070, -304.554, 12.143, 94.247),
                    vector4(-708.602, -925.319, 18.014, 176.300)
                },
            },
            [15] = {
                truck = "phantom",
                trailer = "tr4",
                taskOne = "Deliver vehicles",
                dropString = "Deliver vehicles",
                dropProg = "Unloading vehicles...",
                dropPed = "s_m_y_valet_01",
                itemRewards = {
                    {100, "repairkitadv", math.random(2,3)},
                    {15, "nitrous", 1},
                    {7, "harness", 1},
                },
            },
        },
        illegal = {
            [3] = {
                truck = "phantom",
                trailer = "trailers",
                taskOne = "Transport drugs to the dropoff",
                dropString = "Deliver drugs",
                dropProg = "Unloading drugs...",
                dropPed = "s_m_y_dealer_01",
                itemRewards = {
                    {50, "weed_bud", math.random(2,4)},
                    {50, "oxy", math.random(2,3)},
                    {50, "weed_joint", math.random(2,5)},
                    {20, "meth_bag", math.random(1,2)},
                    {20, "coke_bag", math.random(1,2)},
                    {10, "moonshine", math.random(1,2)},
                },
                dropoffLocations = {
                    vector4(651.866, 593.153, 127.911, 72.875),
                    vector4(-401.808, 1234.179, 324.664, 166.405),
                    vector4(197.979, 1224.503, 224.460, 283.642)
                },
            },
            [5] = {
                truck = "phantom",
                trailer = "trailers",
                taskOne = "Transport stolen materials",
                dropString = "Unload stolen materials",
                dropProg = "Unloading materials...",
                dropPed = "s_m_y_construct_01",
                itemRewards = {
                    {35, "refined_metal", 1},
                    {35, "refined_iron", 1},
                    {35, "refined_electronics", 1},
                    {35, "refined_copper", 1},
                    {35, "refined_plastic", 1},
                    {35, "refined_rubber", 1},
                    {35, "refined_glue", 1},
                },
                dropoffLocations = {
                    vector4(-1111.154, -969.871, 1.216, 34.850),
                    vector4(-2971.950, 73.642, 10.546, 151.536),
                    vector4(831.339, -791.360, 25.264, 107.922)
                },
            },
            [7] = {
                truck = "phantom",
                trailer = "trailers",
                taskOne = "Transport stolen jewelry",
                dropString = "Dropoff stolen jewelry",
                dropProg = "Unloading jewelry...",
                dropPed = "s_f_y_shop_mid",
                itemRewards = {
                    {35, "earrings", math.random(4,6)},
                    {35, "watch", math.random(4,6)},
                    {35, "chain", math.random(4,6)},
                    {35, "rolex", math.random(2,3)},
                    {35, "ring", math.random(4,6)},
                },
                dropoffLocations = {
                    vector4(1704.669, 3764.907, 33.367, 314.257),
                    vector4(1963.665, 5164.222, 46.328, 94.600),
                    vector4(-239.407, 6265.375, 30.489, 229.303)
                },
            },
            [9] = {
                truck = "phantom",
                trailer = "tvtrailer",
                taskOne = "Transport stolen electronics",
                dropString = "Deliver stolen electronics",
                dropProg = "Unloading electronics...",
                dropPed = "g_m_m_mexboss_01",
                itemRewards = {
                    {60, "boombox", 1},
                    {50, "microwave", 1},
                    {45, "pc", 1},
                    {35, "tv", 1},
                    {25, "big_tv", 1},
                    {7, "harness", 1},
                },
                dropoffLocations = {
                    vector4(-77.855, 6561.021, 30.491, 221.194),
                    vector4(1886.839, 3767.304, 31.805, 207.971),
                    vector4(888.973, 3660.710, 31.833, 183.269)
                },
            },
            -- [11] = {
            --     truck = "phantom",
            --     trailer = "trailers",
            --     taskOne = "Transport ammo to the dropoff",
            --     dropString = "Deliver ammo",
            --     dropProg = "Unloading ammo...",
            --     dropPed = "mp_m_exarmy_01",
            --     itemRewards = {
            --         {100, "AMMO_PISTOL", math.random(10,15)},
            --         {35, "AMMO_SMG", math.random(2,3)},
            --     },
            --     dropoffLocations = {
            --         vector4(-350.148, 6080.923, 30.402, 225.765),
            --         vector4(1665.304, 3768.669, 33.804, 43.007),
            --         vector4(-1140.271, 2678.413, 17.094, 218.007)
            --     },
            -- },
            -- [13] = {
            --     truck = "phantom",
            --     trailer = "trailers",
            --     taskOne = "Transport illegal firearms",
            --     dropString = "Deliver stolen weapons",
            --     dropProg = "Unloading weapons...",
            --     dropPed = "s_m_y_blackops_02",
            --     itemRewards = {
            --         {100, "WEAPON_PISTOL", math.random(2,3)},
            --         {100, "WEAPON_SNSPISTOL", math.random(2,3)},
            --         {50, "WEAPON_FNX45", 1},
            --         {35, "WEAPON_FM1_GLOCK19", 1},
            --         {35, "WEAPON_2011", 1},
            --         {35, "WEAPON_M45A1", 1},
            --     },
            --     dropoffLocations = {
            --         vector4(1532.384, 6328.663, 23.279, 55.043),
            --         vector4(-388.473, 6385.150, 13.158, 34.189),
            --         vector4(3328.512, 5151.572, 17.295, 152.116)
            --     }
            -- },
            [15] = {
                truck = "phantom",
                trailer = "trailers",
                taskOne = "Transport counterfeit money",
                dropString = "Deliver counterfeit money",
                dropProg = "Unloading money...",
                dropPed = "mp_m_counterfeit_01",
                itemRewards = {
                    {100, "moneyrolls", math.random(20,25)},
                },
                dropoffLocations = {
                    vector4(-671.427, 5790.213, 16.331, 158.249),
                    vector4(2475.709, 3423.516, 48.891, 118.472),
                    vector4(2620.481, 3465.519, 53.999, 252.923)
                },
            },
            [17] = {
                truck = "phantom",
                trailer = "trailers",
                taskOne = "Transport human organs",
                dropString = "Deliver organs",
                dropProg = "Unloading organs...",
                dropPed = "s_m_y_autopsy_01",
                cashReward = 5000,
                dropoffLocations = {
                    vector4(-127.674, 1921.938, 196.312, 0.421),
                    vector4(177.768, 2812.233, 44.048, 281.345),
                    vector4(2934.731, 4489.523, 46.943, 226.271)
                },
            },
            [20] = {
                truck = "phantom",
                trailer = "trailers",
                taskOne = "Transport nuclear materials",
                dropString = "Deliver nuclear conductors",
                dropProg = "Unloading conductors...",
                dropPed = "s_m_m_scientist_01",
                cashReward = 5000,
                dropoffLocations = {
                    vector4(-1754.315, 3040.987, 31.826, 329.475),
                    vector4(-1803.798, 2960.910, 31.810, 62.337),
                    vector4(-2474.999, 3265.119, 31.831, 151.095)
                },
            }
        }
    }
}