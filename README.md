Special:SpecialPages
Help:Exporting_pages

Special:Export

A bunch of scripts to download an entire wikia / fandom.com wiki's content.
`archiveGitRepo.sh` does too much html manipulation and isn't really reliable.

Wikia is sparse on big pages with a big history, and advises against getting an xml that would weight more than 1.8Mb.
If you want to make a local copy, you probably should use `archiveXmlCurrent.sh`.

todo:
- handle separated allpages https://battle-cats.fandom.com/wiki/Special:AllPages https://pokemon.fandom.com/wiki/Special:AllPages
- xml to git repo
- xml merger (just bunch up all the <page> entries)
- static site generator from xml?

`getAllPages` doesn't seem to work quite properly on split-up Special:AllPages, and skips a bunch. I'm not sure why and I'm giving up doing it as a bash script.

Oops it seems there's an API https://community.fandom.com/api/v1/#!/Search
