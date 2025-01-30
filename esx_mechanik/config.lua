Config                            = {}

Config.DrawDistance               = 10.0
Config.MaxInService               = -1
Config.NPCSpawnDistance           = 200.0
Config.NPCNextToDistance          = 25.0
Config.Vehicles = {
	'rhapsody',
	'asea',
	'asterope',
	'banshee',
	'buffalo'
}

Config.Blips = {
	Mechanic = {
		Pos = vector3(884.7516, -2114.2090, 30.4596),
		Sprite = 446,
		Color = 5,
		Label = "Los Santos Customs"
	},
}

Config.Zones = {
	['mechanik'] = {
		BossMenu = {
			coords = vec3(887.75, -2100.1, 34.55),
			size = vec3(1.05, 2.95, 1.55),
			rotation = 355.0,
            icon = "fa-solid fa-people-roof",
            label = "Zarządzanie",
		},

		MechanicActions = {
			coords = vec3(883.2, -2099.9, 30.5),
			size = vec3(2.3, 0.8, 2.4),
			rotation = 354.5,
			icon = "fa-solid fa-dolly",
            label = "Schowek",
		},

		VehicleSpawner = {
			coords = vec3(869.9, -2120.45, 30.7),
			size = vec3(1.1, 1.4, 2.4),
			rotation = 355.0,
            icon = "fa-solid fa-truck-pickup",
            label = "Garaż",
		},
	},
}

Config.Zones.Vehicles = {
	VehicleDeleter = {
		coords = vec3(852.8101, -2124.1467, 30.5412),
		type  = 28
	},

	VehicleDelivery = {
		coords = vec3(862.1497, -2141.7566, 30.4876),
		type  = 29
	},
}

Config.Towables = {
	vector3(-2480.9, -212.0, 17.4),
	vector3(-2723.4, 13.2, 15.1),
	vector3(-3169.6, 976.2, 15.0),
	vector3(-3139.8, 1078.7, 20.2),
	vector3(-1656.9, -246.2, 54.5),
	vector3(-1586.7, -647.6, 29.4),
	vector3(-1036.1, -491.1, 36.2),
	vector3(-1029.2, -475.5, 36.4),
	vector3(75.2, 164.9, 104.7),
	vector3(-534.6, -756.7, 31.6),
	vector3(487.2, -30.8, 88.9),
	vector3(-772.2, -1281.8, 4.6),
	vector3(-663.8, -1207.0, 10.2),
	vector3(719.1, -767.8, 24.9),
	vector3(-971.0, -2410.4, 13.3),
	vector3(-1067.5, -2571.4, 13.2),
	vector3(-619.2, -2207.3, 5.6),
	vector3(1192.1, -1336.9, 35.1),
	vector3(-432.8, -2166.1, 9.9),
	vector3(-451.8, -2269.3, 7.2),
	vector3(939.3, -2197.5, 30.5),
	vector3(-556.1, -1794.7, 22.0),
	vector3(591.7, -2628.2, 5.6),
	vector3(1654.5, -2535.8, 74.5),
	vector3(1642.6, -2413.3, 93.1),
	vector3(1371.3, -2549.5, 47.6),
	vector3(383.8, -1652.9, 37.3),
	vector3(27.2, -1030.9, 29.4),
	vector3(229.3, -365.9, 43.8),
	vector3(-85.8, -51.7, 61.1),
	vector3(-4.6, -670.3, 31.9),
	vector3(-111.9, 92.0, 71.1),
	vector3(-314.3, -698.2, 32.5),
	vector3(-366.9, 115.5, 65.6),
	vector3(-592.1, 138.2, 60.1),
	vector3(-1613.9, 18.8, 61.8),
	vector3(-1709.8, 55.1, 65.7),
	vector3(-521.9, -266.8, 34.9),
	vector3(-451.1, -333.5, 34.0),
	vector3(322.4, -1900.5, 25.8)
}

Config.TowZones = {}

for k,v in ipairs(Config.Towables) do
	Config.TowZones['Towable' .. k] = {
		Pos   = v,
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Color = { r = 204, g = 204, b = 0 },
		Type  = -1
	}
end

Config.Uniforms = {
	[0] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 7,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 7,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 7,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 7
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 7,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 7,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 7,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 7
		}
	},
	[1] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 1,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 1,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 1,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 1
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 1,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 1,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 1,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 1
		}
	},
	[2] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 7,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 7,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 7,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 7
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 7,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 5,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 5,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 5
		}
	},
	[3] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 3,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 3,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		}
	},
	[4] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 495,   ['torso_2'] = 4,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 4,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		}
	},
	[5] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 8,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 8,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 8,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 8
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 8,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 8,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 8,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 8
		}
	},
	[6] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 9,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 9,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 9,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 9
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 9,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 9,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 9,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 9
		}
	},
	[7] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 3,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 3,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		}
	},
	[8] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 4,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 4,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		}
	},
}