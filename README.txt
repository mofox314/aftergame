AFTERGAME

1. Copy games\_template to a new folder inside games, such as games\hollow-knight.
   Keep one folder per game. Folders starting with _ are ignored.

2. In each game folder, edit:
   title.txt       Game title
   score.txt       A whole number from 1 to 10
   description.txt Your review (plain text; multiple paragraphs are fine)
   cover.svg       Cover image

   You can replace cover.svg with cover.jpg, cover.jpeg, cover.png, or cover.webp.
   If both exist, the JPG/PNG/WebP image takes priority.

3. Double-click build.cmd. It creates games.json and rebuilds site/.
   Open site\index.html to preview the list and its detail pages locally.

PUBLISH UPDATES

The public site is https://mofox314.github.io/aftergame/.
After editing a game folder, double-click build.cmd to export games.json and
preview the rebuilt site. Then open this project in GitHub Desktop, commit the
changed files, and click Push origin. GitHub Actions builds and publishes the
site automatically after the push.

The generated games.json and site/ are local outputs. GitHub Actions generates
them again from the game folders, so they do not need to be committed.
