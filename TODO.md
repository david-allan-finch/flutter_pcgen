# PCGen Flutter Port — TODO & Port Needs

---

## User TODO — implement only when asked

### Done
- [x] a) Feat page: "Qualifies" filter chip — show only feats the character can select
- [x] b) Skill page: "Class" filter chip — show only class skills
- [x] c) Craft / Knowledge / Perform skills: collapsible tree (grouped by Base (Subtype))

### Pending
- [ ] d) Download a game mode (system + data LST files as a zip) and import it into the app

---

## Port Needs — things the port still requires to be complete

### Data Loading
- [ ] LoadContext not reset when switching campaigns of same game mode mid-session
- [x] PRECLASS prereq evaluation (class levels exposed as CL.<key> variables)
- [x] `BONUS:SKILL|LIST|2` — LIST resolution uses `abilityChoices` map for chosen skill (Skill Focus bonus)
- [x] `BONUS:CASTERLEVEL` handling — evaluated per class level; CL and DC shown in spells tab
- [x] `TEMPBONUS` token on abilities — wired into accumulator; ability-sourced TBs shown as checkboxes in Temp Bonus tab
- [ ] `ADDSPELLLEVEL` token on feats
- [x] `QUALIFY` token — override prereqs for an ability
- [x] `ADD:CLASSSKILLS|skill1|skill2` — wired into classSkillNames in PrereqContext
- [ ] `SERVESAS:RACE|Human|Orc` token (PF2e race alternates)

### Rules Engine
- [x] PRECLASS prereq — class levels now in PrereqContext via CL.<key> variables
- [x] Per-level class abilities (ABILITY: at level lines) applied when levelling up
- [x] Unarmed damage from UDAM token — stored on race object (shown via race detail)
- [x] Spell resistance (SR token) displayed on character sheet
- [x] Damage reduction (DR token) displayed on character sheet
- [x] Innate spells (SPELLS token) displayed in spells tab (Innate tab)
- [x] `BONUS:COMBAT|TOHIT|...` combat bonuses wired into attack rolls
- [x] `BONUS:COMBAT|DAMAGE|...` wired into weapon damage
- [x] Domain auto-grant: granted abilities shown in Special Ability tab
- [x] Domain spells shown in domain tab

### Character Sheet / UI
- [x] Character sheet stat block reads from accumulator for ALL bonuses
- [x] Attack/damage calculation wired to bonus accumulator
- [x] Equipment ACP applied to skill rolls
- [x] Equipment MAXDEX cap applied to DEX-based AC
- [x] Armor/shield AC bonus shown on sheet
- [x] Natural attacks from race shown in weapons section (chain-walked)
- [x] Movement speed from race shown on sheet
- [x] Languages tab wired — setRace now walks full ability chain for AUTO_LANG/LANG_BONUS
- [x] Deity weapon proficiency auto-grant — setDeity() grants DEITYWEAP proficiency
- [x] Non-proficient weapon penalty (−4 to attack) — shown on sheet with * marker
- [x] Feat/ability selector — 3-column layout with full description/benefit/prereq detail panel
- [x] Character sheet — full skill table, feat descriptions, all weapon slots with iterative attacks
- [x] PCGen logo — used for app icon (all platforms) and shown in AppBar and About dialog

### Save / Load
- [x] Domain selections persisted in PCG save file
- [x] Ability choices (Skill Focus → Perception) persisted correctly
- [x] Equipment location (equipped slot) persisted in PCG save file

### Export
- [ ] HTML character sheet export
- [ ] PDF character sheet export

### Testing
- [ ] Unit tests: bonus accumulator stacking rules
- [ ] Unit tests: prerequisite evaluation
- [ ] Unit tests: LST token parsing round-trip
- [ ] Integration test: character create → save → load

---
