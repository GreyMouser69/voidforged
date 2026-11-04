#include "../bot.h"
#include "../client.h"
#include "../../common/repositories/doors_repository.h"

void command_zone(Client *c, const Seperator *sep)
{
	int arguments = sep->argnum;
	if (!arguments) {
		c->Message(Chat::White, "Usage: #zone [Zone ID|Zone Short Name] [X] [Y] [Z]");
		return;
	}

	// input: (first arg)
	// zone identifier can be a string of a zone name or its ID
	std::string zone_input = sep->arg[1];
	uint32      zone_id    = 0;

	// if input is id
	if (Strings::IsNumber(zone_input)) {
		zone_id = Strings::ToInt(zone_input);

		// validate
		if (zone_id != 0 && !GetZone(zone_id)) {
			c->Message(Chat::White, fmt::format("Could not find zone by id [{}]", zone_id).c_str());
			return;
		}
	}
	else {
		// validate
		if (!ZoneStore::Instance()->GetZone(zone_input)) {
			c->Message(Chat::White, fmt::format("Could not find zone by short_name [{}]", zone_input).c_str());
			return;
		}

		// validate we got id
		zone_id = ZoneID(zone_input);
		if (zone_id == 0) {
			c->Message(Chat::White, fmt::format("Could not find zone id by short_name [{}]", zone_input).c_str());
			return;
		}
	}

	// if zone identifier is a number and the id is 0, send to safe coordinates of the local zone
	if (Strings::IsNumber(zone_input) && zone_id == 0) {
		c->Message(Chat::White, "Sending you to the safe coordinates of this zone.");

		c->MovePC(
			0.0f,
			0.0f,
			0.0f,
			0.0f,
			0,
			ZoneToSafeCoords
		);
		return;
	}

	// players need the key that the zone's locked entrance door asks for (Sleeper's Tomb, Vex Thal, the Mire)
	if (c->Admin() < AccountStatus::Guide) {
		const auto &key_doors = DoorsRepository::GetWhere(
			content_db,
			fmt::format(
				"dest_zone = '{}' AND zone != dest_zone AND keyitem > 1 AND version = 0",
				Strings::Escape(ZoneName(zone_id))
			)
		);

		bool has_key = key_doors.empty();
		for (const auto &d : key_doors) {
			if (c->KeyRingCheck(d.keyitem) || c->GetInv().HasItem(d.keyitem, 1) != INVALID_INDEX) {
				has_key = true;
				break;
			}
		}

		if (!has_key) {
			const auto *key = database.GetItem(key_doors.front().keyitem);
			c->Message(
				Chat::White,
				fmt::format("You need {} to enter that zone.", key ? key->Name : "the entrance key").c_str()
			);
			return;
		}
	}

	// This block is necessary to clean up any bot objects owned by a Client
	if (RuleB(Bots, Enabled) && zone_id != c->GetZoneID()) {
		Bot::ProcessClientZoneChange(c);
	}

	// fetch zone data
	auto zd = GetZoneVersionWithFallback(zone_id, 0);
	if (zone_id == 0) {
		c->Message(Chat::White, fmt::format("Failed to find zone with fallback [{}]", zone_id).c_str());
		return;
	}

	// coordinates: players always land at the safe spot, so they can't skip past locked doors
	const bool use_coords = sep->IsNumber(2) && c->Admin() >= AccountStatus::Guide;
	if (sep->IsNumber(2) && !use_coords) {
		c->Message(Chat::White, "Coordinates are GM-only; sending you to the zone's safe spot.");
	}

	auto x         = use_coords ? Strings::ToFloat(sep->arg[2]) : 0.0f;
	auto y         = use_coords && sep->IsNumber(3) ? Strings::ToFloat(sep->arg[3]) : 0.0f;
	auto z         = use_coords && sep->IsNumber(4) ? Strings::ToFloat(sep->arg[4]) : 0.0f;
	auto zone_mode = use_coords ? ZoneSolicited : ZoneToSafeCoords;

	c->MovePC(
		zone_id,
		x,
		y,
		z,
		zd ? zd->safe_heading : 0.0f,
		0,
		zone_mode
	);
}
