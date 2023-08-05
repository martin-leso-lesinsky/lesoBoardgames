**API calls:**

*get collection:*
[https://boardgamegeek.com/xmlapi2/collection?username=lesiak]()

*extra detail url Aplikacia:*
[https://boardgamegeek.com/xmlapi2/thing?type=boardgame&amp;versions=0&amp;stats=1&amp;id=310100]()

*extra detail url rozsirenie:*
[https://boardgamegeek.com/xmlapi2/thing?type=boardgameexpansion&amp;versions=0&amp;stats=1&amp;id=121786]()

- v tomto APIcku je info o core game "<link **type**="**boardgameexpansion**" **id**="**27627**" **value**="**Talisman: Revised 4th Edition**" **inbound**="**true**"/>"

https://boardgamegeek.com/xmlapi2/collection?username=lesiak&subtype=boardgameexpansion

https://boardgamegeek.com/xmlapi2/collection?username=lesiak&subtype=boardgame&excludesubtype=boardgameexpansion

/// To DO:

hra_start_page.dart

- scafoldMessage when after syncing got new game
- scafoldMessage when after syncing got new Expansion
- scafoldMessage when after syncing got new plays

 ! Add Check if user is invalid

- finish radio filter buttons = Ordered/Own , Expansions/Games
- Finish Sorting by Plays / Published[will be changed to value] / Name
- Summ allGamesValue, allExpansionsValue to be able display on hra_list_page.dart and statisctic_page.dart

! Add check 10 sec with spinner and scaffoldMessage when you did changes on BG and wanted to fetch changes (there is 2-30 sec. gap with message that content is preparing ))


FIX: hras_list_page.dart - games and Plays  did not remember data user need to do fetch again.
