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

GITHUB PAGES

Create a public GitHub repository and upload the contents of this folder.
In repository Settings > Pages, choose GitHub Actions as the source.
The included workflow builds and deploys the site whenever you push to main.
The address is https://YOUR-USERNAME.github.io/REPOSITORY-NAME/.

Your local build does not upload files. After editing, commit and push the
changed game folders to GitHub to update the public site.
