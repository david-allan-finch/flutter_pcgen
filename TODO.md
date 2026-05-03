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
- [ ] `BONUS:SKILL|LIST|2` — LIST resolution uses `abilityChoices` map for chosen skill (Skill Focus bonus)
- [ ] `BONUS:CASTERLEVEL` handling
- [ ] `TEMPBONUS` token on abilities (temporary bonus application)
- [ ] `ADDSPELLLEVEL` token on feats
- [ ] `QUALIFY` token — override prereqs for an ability
- [ ] `ADD:CLASSSKILLS|skill1|skill2` — class-granted extra class skills
- [ ] `SERVESAS:RACE|Human|Orc` token (PF2e race alternates)

### Rules Engine
- [x] PRECLASS prereq — class levels now in PrereqContext via CL.<key> variables
- [ ] Per-level class abilities (ABILITY: at level lines) applied when levelling up
- [ ] Unarmed damage from UDAM token fed into character sheet
- [ ] Spell resistance (SR token) displayed and factored in
- [ ] Damage reduction (DR token) displayed on character sheet
- [ ] Innate spells (SPELLS token) displayed in spells tab
- [ ] `BONUS:COMBAT|TOHIT|...` and other combat bonuses used in attack calculation
- [ ] `BONUS:COMBAT|DAMAGE|...` used in damage calculation
- [ ] Domain auto-grant: granted abilities shown in Special Ability tab
- [ ] Domain spells shown in domain tab

### Character Sheet / UI
- [ ] Character sheet stat block reads from accumulator for ALL bonuses (not just racial)
- [ ] Attack/damage calculation wired to bonus accumulator
- [ ] Equipment ACP applied to skill rolls (partially done)
- [ ] Equipment MAXDEX cap applied to DEX-based AC
- [ ] Armor/shield AC bonus shown on sheet
- [ ] Natural attacks from race shown in weapons section
- [x] Movement speed from race shown on sheet
- [x] Languages tab wired — setRace now walks full ability chain for AUTO_LANG/LANG_BONUS
- [ ] Deity weapon proficiency auto-grant
- [ ] Non-proficient weapon penalty (−4 to attack)

### Save / Load
- [ ] Domain selections persisted in PCG save file
- [ ] Ability choices (Skill Focus → Perception) persisted correctly
- [ ] Equipment location (equipped slot) persisted in PCG save file

### Export
- [ ] HTML character sheet export
- [ ] PDF character sheet export

### Testing
- [ ] Unit tests: bonus accumulator stacking rules
- [ ] Unit tests: prerequisite evaluation
- [ ] Unit tests: LST token parsing round-trip
- [ ] Integration test: character create → save → load

---
