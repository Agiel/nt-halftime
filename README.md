# nt-halftime

Neotokyo SourceMod plugin that stops the side-swapping until halftime, whereupon it optionally resets player scores.

## ConVars
_sm_nt_halftime_enabled_ (Default: 0)  
Enable halftime

_sm_nt_halftime_reset_  (Default: 1)  
Whether or not to reset scores when swapping sides.

## Changelog

### 0.0.2
* Added message letting players know it's the last round of the first half.
* Bail out when match isn't live or when paused.
* If reset is enabled, bump everyone up to lieutenant when entering sudden death.

### 0.0.1
* Initial release