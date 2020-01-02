A bunch of scripts to download an entire wikia / fandom.com wiki's content.


The `scrapper_*` scripts were before I figured out that there actually was an API. They aren't really reliable because of the amount of html wrangling they do, and that querying Special:AllPages on a big wiki is messy. `scrapper_archiveGitRepo.sh` relies too much on html parsing and will probably keep breaking. I guess I just keep those scripts in here for posterity (and if the API disappears at one point, who knows).


tl;dr use `sh archiveXmlCurrent.sh community`


todo:
- xml to git repo
- xml merger (just bunch up all the <page> entries)
- static site generator from xml?
- proper htmlEntities convertion
```
echo '&amp;&rsquo;¥' | recode html..ascii
#=>&recode: Untranslatable input in step `ISO-10646-UCS-2..ANSI_X3.4-1968'
echo '&amp;&rsquo;¥' | recode html
#=>&’Â¥
echo '&amp;&rsquo;¥' | perl -MHTML::Entities -pe 'decode_entities($_);'
#Wide character in print at -e line 1, <> line 1.
#&’Â¥
```


Special:SpecialPages
Help:Exporting_pages
Special:Export