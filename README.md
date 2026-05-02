# MogMountExtended

A World of Warcraft addon that lets you assign flying, ground, and aquatic mounts per transmog outfit. When you switch outfits, your assigned mounts and title switch automatically. A smart summon macro summons the right mount based on your current context.

This is an unofficial community fork of the original [MogMount by its original author on CurseForge](https://www.curseforge.com/wow/addons/mogmount), picking up where the original left off at version 0.2.3. All original credit goes to the original author.

---

## What's New in This Fork

### Bug Fixes

**Collection sets disappearing from transmog tabs**
The original addon overrode Blizzard's `UpdateTabs` function entirely, which caused other collection set tabs (Sets, Custom Sets, Situations) to disappear. Fixed by replacing the override with `hooksecurefunc` so Blizzard's own tab logic runs normally and MogMount just adds its tab on top.

**`GetSpellInfo` deprecated**
The original code used `GetSpellInfo()` which was deprecated in patch 10.1. Replaced with `C_Spell.GetSpellName()`.

---

### New Features

**Aquatic mount socket in transmog window**
A third mount slot (aquatic) now appears in the character preview sidebar below the flying and ground slots, matching the existing slot style. Click it to open the Mounts tab directly.

**Aquatic section in the Mounts tab**
The Mounts tab now has three sections — Flying, Ground, and Aquatic — each with a 3D preview model and a scrollable mount list. Previously only Flying and Ground were shown and Aquatic was global-only via the Settings panel.

**Per-outfit aquatic mount assignment**
Aquatic mount can now be assigned per outfit just like flying and ground, both in the transmog window sidebar and in the Settings panel dropdowns.

**"Show All Mounts in Flying" filter**
A filter dropdown (funnel icon, top-right of the Mounts tab) now has two checkboxes:
- **Show Flying in Ground** — allows flying mounts to appear in the ground mount list (was wired up in the original but the toggle logic was never implemented)
- **Show All Mounts in Flying** — removes all type filtering from the flying list, showing every collected mount

**Smart macro with dynamic icon and tooltip**
The MogMount macro now uses `#showtooltip` with WoW's native macro conditionals, so the tooltip and icon update live based on your current context without any addon overhead:
- Default: ground mount icon and tooltip
- Flyable area: flying mount
- Swimming + Ctrl: aquatic mount
- Shift: special mount (repair/vendor mount)
- Alt: alternative mount

The macro icon also updates automatically when you change zones (`ZONE_CHANGED_NEW_AREA`) and when you equip a different outfit (`PLAYER_EQUIPMENT_CHANGED`).

**Improved mount slot spacing**
The three mount slots in the character preview sidebar are better spaced from the armour slots, with a clear visual gap between them.

---

## How to Use

### Initial Setup
1. Open the Transmogrify window at any transmog NPC
2. Click the **Mounts** tab at the top
3. If you haven't set up the addon yet, you'll see a reminder with two buttons:
   - **Open Keybinds** — set a keybind for the MogMount summon action
   - **Create Macro** — creates the MogMount macro and attaches it to your cursor so you can drag it to an action bar
4. Once either is set up the reminder disappears and the full mount UI appears

### Assigning Mounts
- In the Mounts tab, click any mount in the Flying, Ground, or Aquatic list to assign it to the current outfit
- The 3D preview on the left updates as you hover over mounts
- You can also click the mount slot icons on the character preview sidebar to jump to the Mounts tab
- Click the X button that appears on a slot icon to clear that assignment
- Unassigned slots fall back to the default set in the Settings panel, or random if no default is set

### Summon Behaviour
| Situation | Mount summoned |
|---|---|
| Flyable area | Outfit flying mount → default flying → random flying |
| Non-flyable / Ctrl held | Outfit ground mount → default ground → random ground |
| Swimming + Ctrl | Outfit aquatic mount → default aquatic → random aquatic |
| Shift | Default special mount (repair bear / vendor yak) |
| Alt | Default alternative mount |
| Already mounted | Dismount |
| In vehicle | Exit vehicle |

### Title Auto-Swap
Each outfit can have a title assigned via the dropdown at the top of the character preview. When that outfit is active, the title switches automatically. Clearing the assignment reverts to no title.

---

## Settings Panel

Open via **Escape → Options → MogMount** or via the gear dropdown in the Mounts tab.

- **Default mounts** — Flying, Ground, Aquatic, Special, and Alternative defaults used as fallback when no outfit-specific mount is assigned
- **Per-outfit sections** — Title, Flying, Ground, and Aquatic dropdowns for each of your saved outfits

---

## Known Limitations

- The filter dropdown (Show All / Show Flying in Ground) requires the macro or keybind to be set up first — it's hidden while the setup reminder is showing
- Aquatic mount list only shows mounts with aquatic-specific type IDs. Some hybrid mounts that can swim but are primarily ground or flying mounts will not appear in the aquatic list by design
- Special mount slot is global-only (not per outfit) — this matches the original addon's design since special mounts are utility mounts not tied to appearance

---

## Files Changed from Original

| File | Changes |
|---|---|
| `Core.lua` | Aquatic socket UI, 3-panel Mounts tab layout, UpdateTabs fix, smart macro, icon watcher, equipment event |
| `Shared.lua` | Flying mount type filter fix, expanded aquatic type IDs, aquatic field in CreateEmptyOutfit |
| `Settings.lua` | Per-outfit aquatic dropdown added to each outfit section |

`Bindings.xml`, `Core.xml`, `Settings.xml`, `Initialization.lua`, and `MogMount.toc` are unchanged from the original.

---

## Interface Version

Built and tested against **Interface 120000 / 120001** (The War Within).
