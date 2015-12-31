## sigsegv's SourceMod plugins for MvM

### mvm-unfilterdeathnotices
Normally, in MvM mode, death notices for bot deaths only show up for players if one or more of these conditions is true:
- the player was the killer
- the player was the assister
- the bot is a MiniBoss

This plugin adds a console variable, *sm_mvm_unfilter_deathnotices* (default 1). When nonzero, the plugin will force all death notices from robot deaths to appear for all players.
