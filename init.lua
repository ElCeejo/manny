manny = {}

creatura.register_mob("manny:manny", {
	-- Engine Parameters
	visual_size = {x = 10, y = 10},
	mesh = "manny_manny.b3d",
	textures = {
		"manny_manny.png"
	},

	-- Creatura Parameters
	max_health = 1,
	damage = 0,
	speed = 1,
	tracking_range = 8,
	despawn_after = 100,
	stepheight = 1.1,
	sounds = {
		death = {
			name = "manny_death",
			gain = 3,
			distance = 128
		},
		lit = {
			name = "tnt_gunpowder_burning",
			gain = 1,
			distance = 16
		}
	},
	hitbox = {
		width = 0.15,
		height = 0.3
	},
	animations = {
		stand = {range = {x = 1, y = 39}, speed = 20, frame_blend = 0.3, loop = true},
		walk = {range = {x = 51, y = 69}, speed = 20, frame_blend = 0.3, loop = true},
		run = {range = {x = 81, y = 99}, speed = 45, frame_blend = 0.3, loop = true},
		eat = {range = {x = 111, y = 119}, speed = 20, frame_blend = 0.1, loop = false}
	},

	-- Behavior Parameters
	is_skittish_mob = true,
	follow = {
		"manny:vinegar",
		"manny:baking_soda"
	},

	-- Animalia Parameters
	flee_puncher = true,
	catch_with_net = true,
	catch_with_lasso = false,

	-- Functions
	utility_stack = {
		animalia.mob_ai.basic_wander,
		animalia.mob_ai.tamed_follow_owner,
	},

	activate_func = function(self)
		animalia.initialize_api(self)

		self.fed_vinegar = self:recall("fed_vinegar") or 0
		self.fed_baking_soda = self:recall("fed_baking_soda") or 0
		self.hammy_countdown = self:recall("hammy_countdown") or 5
	end,

	step_func = function(self)
		local hammy_countdown = self.hammy_countdown or 5

		if self.fed_baking_soda > 0
		and self.fed_vinegar > 0 then
			if self:timer(0.2) then
				self:play_sound("lit")
			end
			hammy_countdown = hammy_countdown - self.dtime
		end

		if hammy_countdown <= 0 then
			local hammy_strength = (self.fed_baking_soda + self.fed_vinegar) / 2
			
			tnt.boom(self.stand_pos, {
				radius = hammy_strength
			})

			self:play_sound("death")

			self.object:remove()
			return
		end

		self.hammy_countdown = self:memorize("hammy_countdown", hammy_countdown)

	end,

	death_func = function(self)
		if self:get_utility() ~= "animalia:die" then
			self:initiate_utility("animalia:die", self)
		end
	end,

	on_rightclick = function(self, clicker)
		local fed_baking_soda = self.fed_baking_soda
		local fed_vinegar = self.fed_vinegar
		if animalia.feed(self, clicker, false, false) then
			local item = clicker and clicker:get_wielded_item()
			local name = item and item:get_name()

			if name == "manny:baking_soda" then
				fed_baking_soda = fed_baking_soda + 1
			end

			if name == "manny:vinegar" then
				fed_vinegar = fed_vinegar + 1
			end
		end

		self.fed_baking_soda = self:memorize("fed_baking_soda", fed_baking_soda)
		self.fed_vinegar = self:memorize("fed_vinegar", fed_vinegar)
	end,

	on_punch = animalia.punch
})

creatura.register_spawn_item("manny:manny", {
	col1 = "e7cfba",
	col2 = "efa968"
})


minetest.register_craftitem("manny:baking_soda", {
	description = "Baking Soda",
	inventory_image = "manny_baking_soda.png",
	groups = {flammable = 2},
})


minetest.register_craftitem("manny:vinegar", {
	description = "Vinegar",
	inventory_image = "manny_vinegar.png",
	groups = {flammable = 2},
})
